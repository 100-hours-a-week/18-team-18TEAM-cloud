#!/usr/bin/env bash

set -euo pipefail

export KUBECONFIG=/etc/kubernetes/admin.conf

NODE="${1:-bizkit-prod-k8s-app-1}"
NAMESPACE="${2:-prod-be}"

echo "[1/4] Cordoning ${NODE}"
kubectl cordon "${NODE}"

echo "[2/4] Finding prod-be pod on ${NODE}"
pod="$(kubectl get pod -n "${NAMESPACE}" -l app.kubernetes.io/name=be,app.kubernetes.io/part-of=bizkit,environment=prod -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.nodeName}{"\n"}{end}' | awk -v node="${NODE}" '$2 == node {print $1; exit}')"

if [[ -n "${pod}" ]]; then
  echo "[3/4] Deleting ${pod} so Deployment can reschedule it away from ${NODE}"
  kubectl delete pod -n "${NAMESPACE}" "${pod}" --wait=true
else
  echo "[3/4] No prod-be pod currently bound to ${NODE}"
fi

echo "[4/4] Current prod-be pods"
kubectl get pods -n "${NAMESPACE}" -o wide

echo "[done] Node status"
kubectl get node "${NODE}"
