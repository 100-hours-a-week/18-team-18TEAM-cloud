#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_env_file "${1:-/etc/bizkit/bootstrap.env}"
require_root

require_env WORKER_NAME
require_env WORKER_IP
require_env CONTROL_PLANE_ENDPOINT
require_env BOOTSTRAP_TOKEN
require_env DISCOVERY_TOKEN_CA_CERT_HASH
require_env NODE_POOL

set_node_hostname "${WORKER_NAME}"
ensure_control_plane_endpoint_mapping
bootstrap_common_node

# shellcheck disable=SC1091
source /etc/bizkit/kubelet-defaults.env

WORKER_NODE_LABELS="${WORKER_NODE_LABELS:-nodepool=${NODE_POOL},environment=shared}"
WORKER_NODE_TAINTS="${WORKER_NODE_TAINTS:-}"

cat >/tmp/bizkit-kubeadm-join-worker.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: "${CONTROL_PLANE_ENDPOINT}"
    token: "${BOOTSTRAP_TOKEN}"
    caCertHashes:
      - "${DISCOVERY_TOKEN_CA_CERT_HASH}"
  timeout: "5m0s"
nodeRegistration:
  name: "${WORKER_NAME}"
  criSocket: "unix:///var/run/crio/crio.sock"
  kubeletExtraArgs:
    - name: "node-ip"
      value: "${WORKER_IP}"
    - name: "node-labels"
      value: "${WORKER_NODE_LABELS}"
    - name: "register-with-taints"
      value: "${WORKER_NODE_TAINTS}"
    - name: "kube-reserved"
      value: "${KUBE_RESERVED}"
    - name: "system-reserved"
      value: "${SYSTEM_RESERVED}"
    - name: "eviction-hard"
      value: "${EVICTION_HARD}"
EOF

kubeadm join --config /tmp/bizkit-kubeadm-join-worker.yaml
log "Worker node joined."
