#!/usr/bin/env bash

set -euo pipefail

export KUBECONFIG=/etc/kubernetes/admin.conf

NODE="${1:-bizkit-prod-k8s-app-1}"

echo "[1/4] Current kube-system pods on ${NODE}"
kubectl get pods -n kube-system -o wide --field-selector "spec.nodeName=${NODE}" | egrep 'NAME|kube-proxy|node-local-dns|coredns|calico-node'

for selector in 'k8s-app=kube-proxy' 'k8s-app=node-local-dns'; do
  pod="$(kubectl get pod -n kube-system -l "${selector}" --field-selector "spec.nodeName=${NODE}" -o jsonpath='{.items[0].metadata.name}')"
  if [[ -n "${pod}" ]]; then
    echo "[2/4] Restarting ${selector} pod ${pod} on ${NODE}"
    kubectl delete pod -n kube-system "${pod}" --wait=true
  fi
done

echo "[3/4] Waiting for daemonset pods to come back"
for selector in 'k8s-app=kube-proxy' 'k8s-app=node-local-dns'; do
  for _ in $(seq 1 24); do
    ready="$(kubectl get pod -n kube-system -l "${selector}" --field-selector "spec.nodeName=${NODE}" -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null || true)"
    if [[ "${ready}" == "true" ]]; then
      break
    fi
    sleep 5
  done
done

echo "[4/4] Current kube-system pods on ${NODE}"
kubectl get pods -n kube-system -o wide --field-selector "spec.nodeName=${NODE}" | egrep 'NAME|kube-proxy|node-local-dns|coredns|calico-node'

echo "[done] prod-be snapshot"
kubectl get pods -n prod-be -o wide
