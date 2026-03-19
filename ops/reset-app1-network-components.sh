#!/usr/bin/env bash
set -euo pipefail

KUBECTL="sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl"
NODE="${1:-bizkit-prod-k8s-app-1}"

echo "=== cordon node ==="
$KUBECTL cordon "$NODE" >/dev/null || true
$KUBECTL get node "$NODE"

echo "=== delete temporary probe pod if present ==="
$KUBECTL delete pod -n prod-be app1-prod-be-network-probe --ignore-not-found --wait=false || true

echo "=== restart app-1 network daemonset pods ==="
for ns_name in \
  "kube-system calico-node" \
  "kube-system kube-proxy" \
  "kube-system node-local-dns"
do
  ns="${ns_name%% *}"
  name="${ns_name##* }"
  pod="$($KUBECTL get pods -n "$ns" -o wide --field-selector "spec.nodeName=${NODE}" | awk -v n="$name" '$1 ~ n {print $1; exit}')"
  if [[ -n "${pod}" ]]; then
    echo "deleting ${ns}/${pod}"
    $KUBECTL delete pod -n "$ns" "$pod" --wait=false
  fi
done

echo "=== wait and show recreated pods on node ==="
sleep 10
$KUBECTL get pods -n kube-system -o wide --field-selector "spec.nodeName=${NODE}"
