#!/usr/bin/env bash
set -euo pipefail

KUBECTL="sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl"
NODE="${1:-bizkit-prod-k8s-app-1}"

pod="$($KUBECTL get pods -n kube-system -o wide --field-selector "spec.nodeName=${NODE}" | awk '/kube-proxy/ {print $1; exit}')"

if [[ -z "${pod}" ]]; then
  echo "kube-proxy pod not found on ${NODE}" >&2
  exit 1
fi

echo "deleting kube-system/${pod}"
$KUBECTL delete pod -n kube-system "$pod" --wait=false
sleep 10
$KUBECTL get pods -n kube-system -o wide --field-selector "spec.nodeName=${NODE}"
