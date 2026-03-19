#!/usr/bin/env bash

set -euo pipefail

export KUBECONFIG=/etc/kubernetes/admin.conf

echo "[1/3] Deleting prod-fe HPA"
kubectl delete hpa -n prod-fe fe --ignore-not-found=true

echo "[2/3] Scaling prod-fe deployment to 0"
kubectl scale deployment -n prod-fe fe --replicas=0

echo "[3/3] Current prod-fe state"
kubectl get deploy,hpa,pods -n prod-fe -o wide
