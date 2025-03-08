#!/bin/bash
set -euo pipefail

ERROR_LOG="error.log"

error_exit() {
    echo "[ERROR] Ошибка в строке $1" >> "$ERROR_LOG"
    exit 1
}

trap 'error_exit $LINENO' ERR

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Начало развертывания..."

# сетевые политики
# 1. default-deny-all – блокирует весь трафик для всех подов
# 2. allow-front-back – разрешает обмен трафиком между подами с role=front-end и role=back-end-api
# 3. allow-admin-front-back – разрешает обмен трафиком между подами с role=admin-front-end и role=admin-back-end-api
cat <<'EOF' > non-admin-api-allow.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-front-back
spec:
  podSelector:
    matchExpressions:
    - key: role
      operator: In
      values:
      - front-end
      - back-end-api
  ingress:
  - from:
    - podSelector:
        matchExpressions:
        - key: role
          operator: In
          values:
          - front-end
          - back-end-api
  egress:
  - to:
    - podSelector:
        matchExpressions:
        - key: role
          operator: In
          values:
          - front-end
          - back-end-api
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-admin-front-back
spec:
  podSelector:
    matchExpressions:
    - key: role
      operator: In
      values:
      - admin-front-end
      - admin-back-end-api
  ingress:
  - from:
    - podSelector:
        matchExpressions:
        - key: role
          operator: In
          values:
          - admin-front-end
          - admin-back-end-api
  egress:
  - to:
    - podSelector:
        matchExpressions:
        - key: role
          operator: In
          values:
          - admin-front-end
          - admin-back-end-api
  policyTypes:
  - Ingress
  - Egress
EOF

echo "Файл non-admin-api-allow.yaml создан успешно"

kubectl run front-end-app --image=nginx --labels=role=front-end --expose --port=80
kubectl run back-end-api-app --image=nginx --labels=role=back-end-api --expose --port=80
kubectl run admin-front-end-app --image=nginx --labels=role=admin-front-end --expose --port=80
kubectl run admin-back-end-api-app --image=nginx --labels=role=admin-back-end-api --expose --port=80

echo "Сервисы созданы успешно"

# применение сетевых политик
kubectl apply -f non-admin-api-allow.yaml

echo "Сетевые политики применены успешно"

# функция проверки трафика
# Параметры:
#   $1 – метка (role) для временного test-pod, имитирующего источник запроса
#   $2 – имя сервиса (имя, как создано командой kubectl run) для обращения
#   $3 – ожидаемый результат ("allowed" или "denied")
test_connectivity() {
    local source_label=$1
    local target_service=$2
    local expected=$3
    local test_pod="test-${source_label}-$(date +%s%N)"  

    echo "Проверка трафика от pod с label ${source_label} к сервису ${target_service} (ожидается: ${expected})..."

    set +e
    kubectl run "$test_pod" --rm -i --image=alpine --labels=role=$source_label --restart=Never --command -- \
         sh -c "apk add --no-cache wget >/dev/null 2>&1 && wget -qO- --timeout=2 http://${target_service}"
    RC=$?
    set -e

    if [ "$expected" == "allowed" ]; then
         if [ $RC -eq 0 ]; then
              echo -e "${GREEN}Трафик от ${source_label} к ${target_service} разрешен.${NC}"
         else
              echo -e "${RED}Ошибка: Трафик от ${source_label} к ${target_service} должен быть разрешен, но соединение не установлено.${NC}"
         fi
    elif [ "$expected" == "denied" ]; then
         if [ $RC -ne 0 ]; then
              echo -e "${GREEN}Трафик от ${source_label} к ${target_service} запрещен, как и ожидалось.${NC}"
         else
              echo -e "${RED}Ошибка: Трафик от ${source_label} к ${target_service} должен быть запрещен, но соединение установлено.${NC}"
         fi
    fi
}

echo "Ожидаем, стабилизации сервисов и политик ..."
sleep 15

# Тестирование разрешённых соединений:
# front-end ↔ back-end-api
test_connectivity front-end back-end-api-app allowed
# admin-front-end ↔ admin-back-end-api
test_connectivity admin-front-end admin-back-end-api-app allowed

# Тестирование запрещённых соединений:
# Попытка доступа от front-end к admin-front-end (между группами)
test_connectivity front-end admin-front-end-app denied
# Попытка доступа от back-end-api к admin-back-end-api
test_connectivity back-end-api admin-back-end-api-app denied

echo "Проверка трафика завершена"

echo "Скрипт завершён успешно"
