#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_env_file "${1:-/etc/bizkit/bootstrap.env}"
require_root

require_env CONTROL_PLANE_NAME
require_env CONTROL_PLANE_IP
require_env CONTROL_PLANE_ENDPOINT
require_env BOOTSTRAP_TOKEN
require_env DISCOVERY_TOKEN_CA_CERT_HASH
require_env CERTIFICATE_KEY

set_node_hostname "${CONTROL_PLANE_NAME}"
ensure_control_plane_endpoint_mapping
bootstrap_common_node

# shellcheck disable=SC1091
source /etc/bizkit/kubelet-defaults.env

cat >/tmp/bizkit-kubeadm-join-control-plane.yaml <<EOF
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
  name: "${CONTROL_PLANE_NAME}"
  criSocket: "unix:///var/run/crio/crio.sock"
  kubeletExtraArgs:
    - name: "node-ip"
      value: "${CONTROL_PLANE_IP}"
    - name: "kube-reserved"
      value: "${KUBE_RESERVED}"
    - name: "system-reserved"
      value: "${SYSTEM_RESERVED}"
    - name: "eviction-hard"
      value: "${EVICTION_HARD}"
controlPlane:
  localAPIEndpoint:
    advertiseAddress: "${CONTROL_PLANE_IP}"
    bindPort: 6443
  certificateKey: "${CERTIFICATE_KEY}"
EOF

kubeadm join --config /tmp/bizkit-kubeadm-join-control-plane.yaml
log "Additional control plane node joined."
