#!/bin/bash
# Создание ролей для Kubernetes

# cluster-administrator
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-administrator
rules:
- apiGroups: [""]
  resources: ["secrets", "pods", "services", "endpoints", "configmaps"]
  verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
EOF

# cluster-readonly-user
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-readonly-user
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch"]
EOF

# cluster-configurator
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-configurator
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "configmaps"]
  verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
EOF

echo "Роли созданы успешно"
