#!/usr/bin/env bash
set -euo pipefail

KUBECTL="sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl"
NODE="${1:-bizkit-prod-k8s-app-1}"
NAMESPACE="${2:-prod-be}"
POD_NAME="${3:-app1-prod-be-network-probe}"
IMAGE="${IMAGE:-busybox:1.36.1}"

was_unschedulable="$($KUBECTL get node "$NODE" -o jsonpath='{.spec.unschedulable}')"

cleanup() {
  $KUBECTL delete pod -n "$NAMESPACE" "$POD_NAME" --ignore-not-found --wait=false >/dev/null 2>&1 || true
  if [[ "$was_unschedulable" == "true" ]]; then
    $KUBECTL cordon "$NODE" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

if [[ "$was_unschedulable" == "true" ]]; then
  $KUBECTL uncordon "$NODE"
fi

cat <<EOF | $KUBECTL apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${POD_NAME}
  namespace: ${NAMESPACE}
  labels:
    app.kubernetes.io/name: be
    app.kubernetes.io/part-of: bizkit
    environment: prod
spec:
  nodeName: ${NODE}
  restartPolicy: Never
  terminationGracePeriodSeconds: 0
  containers:
    - name: probe
      image: ${IMAGE}
      command: ["sh", "-c", "sleep 600"]
      resources:
        requests:
          cpu: 10m
          memory: 16Mi
        limits:
          cpu: 50m
          memory: 64Mi
EOF

$KUBECTL wait -n "$NAMESPACE" --for=condition=Ready "pod/${POD_NAME}" --timeout=120s

echo "=== nslookup kubernetes.default.svc.cluster.local ==="
$KUBECTL exec -n "$NAMESPACE" "$POD_NAME" -- nslookup kubernetes.default.svc.cluster.local

echo "=== nslookup mysql.prod.bizkit.private ==="
$KUBECTL exec -n "$NAMESPACE" "$POD_NAME" -- nslookup mysql.prod.bizkit.private

echo "=== nslookup redis.prod.bizkit.private ==="
$KUBECTL exec -n "$NAMESPACE" "$POD_NAME" -- nslookup redis.prod.bizkit.private

echo "=== tcp 3306 mysql.prod.bizkit.private ==="
$KUBECTL exec -n "$NAMESPACE" "$POD_NAME" -- sh -lc 'nc -vz -w 3 mysql.prod.bizkit.private 3306'

echo "=== tcp 6379 redis.prod.bizkit.private ==="
$KUBECTL exec -n "$NAMESPACE" "$POD_NAME" -- sh -lc 'nc -vz -w 3 redis.prod.bizkit.private 6379'

echo "=== https 443 bizkit-img.s3.ap-northeast-2.amazonaws.com ==="
$KUBECTL exec -n "$NAMESPACE" "$POD_NAME" -- sh -lc 'wget -S --spider --timeout=5 https://bizkit-img.s3.ap-northeast-2.amazonaws.com 2>&1'

echo "probe completed successfully"
