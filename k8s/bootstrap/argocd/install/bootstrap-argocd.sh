#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$(cd "${SCRIPT_DIR}/../apps" && pwd)"
NAMESPACE="${ARGOCD_NAMESPACE:-system}"
RELEASE_NAME="${ARGOCD_RELEASE_NAME:-argocd}"
CHART="${ARGOCD_HELM_CHART:-argo/argo-cd}"
CHART_VERSION="${ARGOCD_CHART_VERSION:-}"

kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"
kubectl apply -k "${SCRIPT_DIR}"

helm repo add argo https://argoproj.github.io/argo-helm >/dev/null 2>&1 || true
helm repo update argo

HELM_ARGS=(
  upgrade --install "${RELEASE_NAME}" "${CHART}"
  --namespace "${NAMESPACE}"
  --create-namespace
  -f "${SCRIPT_DIR}/values.yaml"
)

if [[ -n "${CHART_VERSION}" ]]; then
  HELM_ARGS+=(--version "${CHART_VERSION}")
fi

helm "${HELM_ARGS[@]}"

kubectl rollout status deployment/"${RELEASE_NAME}"-server -n "${NAMESPACE}" --timeout=5m
kubectl rollout status deployment/"${RELEASE_NAME}"-repo-server -n "${NAMESPACE}" --timeout=5m
kubectl rollout status statefulset/"${RELEASE_NAME}"-application-controller -n "${NAMESPACE}" --timeout=5m
kubectl rollout status deployment/"${RELEASE_NAME}"-applicationset-controller -n "${NAMESPACE}" --timeout=5m || true
kubectl rollout status deployment/"${RELEASE_NAME}"-redis -n "${NAMESPACE}" --timeout=5m || true

kubectl apply -k "${APPS_DIR}"

echo
echo "Argo CD bootstrap completed."
echo "Access UI with:"
echo "  kubectl -n ${NAMESPACE} port-forward svc/${RELEASE_NAME}-server 8080:80"
