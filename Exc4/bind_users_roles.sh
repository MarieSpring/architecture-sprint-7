#!/bin/bash
# Скрипт, чтобы связать пользователей с ролями

# readonly-user к роли cluster-readonly-user
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: binding-readonly-user
subjects:
- kind: User
  name: readonly-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-readonly-user
  apiGroup: rbac.authorization.k8s.io
EOF

# configurator-user к роли cluster-configurator
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: binding-configurator-user
subjects:
- kind: User
  name: configurator-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-configurator
  apiGroup: rbac.authorization.k8s.io
EOF

# administrators к роли cluster-administrator
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: binding-admin-group
subjects:
- kind: Group
  name: administrators
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-administrator
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Пользователи к ролям привязаны успешно"
