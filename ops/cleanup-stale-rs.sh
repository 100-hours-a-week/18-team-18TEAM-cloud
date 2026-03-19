#!/usr/bin/env bash

set -euo pipefail

export KUBECONFIG=/etc/kubernetes/admin.conf

NAMESPACE="${1:?namespace is required}"
RS_NAME="${2:?replicaset name is required}"

HASH="${RS_NAME##*-}"

echo "[1/3] Scaling ReplicaSet ${RS_NAME} to 0 in ${NAMESPACE}"
kubectl scale rs -n "${NAMESPACE}" "${RS_NAME}" --replicas=0

echo "[2/3] Deleting pods with pod-template-hash=${HASH}"
kubectl delete pod -n "${NAMESPACE}" -l "pod-template-hash=${HASH}" --ignore-not-found=true --wait=true

echo "[3/3] Current ReplicaSets and pods in ${NAMESPACE}"
kubectl get rs -n "${NAMESPACE}" -o wide
kubectl get pods -n "${NAMESPACE}" -o wide
