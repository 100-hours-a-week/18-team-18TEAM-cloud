#!/usr/bin/env bash
set -euo pipefail

KUBECTL="sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl"

cat <<'EOF' >/tmp/coredns-system-only-patch.yaml
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: node-pool
                    operator: In
                    values:
                      - system
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                topologyKey: kubernetes.io/hostname
                labelSelector:
                  matchExpressions:
                    - key: k8s-app
                      operator: In
                      values:
                        - kube-dns
EOF

$KUBECTL patch deploy -n kube-system coredns --patch-file /tmp/coredns-system-only-patch.yaml
$KUBECTL rollout status deploy -n kube-system coredns --timeout=180s
$KUBECTL get pods -n kube-system -l k8s-app=kube-dns -o wide
