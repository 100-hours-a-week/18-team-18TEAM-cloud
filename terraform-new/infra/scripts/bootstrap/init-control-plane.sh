#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

load_env_file "${1:-/etc/bizkit/bootstrap.env}"
require_root

require_env CLUSTER_NAME
require_env KUBERNETES_VERSION
require_env CONTROL_PLANE_NAME
require_env CONTROL_PLANE_IP
require_env CONTROL_PLANE_ENDPOINT
require_env SERVICE_SUBNET
require_env POD_SUBNET

set_node_hostname "${CONTROL_PLANE_NAME}"
ensure_control_plane_endpoint_mapping
bootstrap_common_node

# shellcheck disable=SC1091
source /etc/bizkit/kubelet-defaults.env

cat >/tmp/bizkit-kubeadm-init.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
nodeRegistration:
  name: "${CONTROL_PLANE_NAME}"
  criSocket: "unix:///var/run/crio/crio.sock"
  taints:
    - key: "node-role.kubernetes.io/control-plane"
      effect: "NoSchedule"
  kubeletExtraArgs:
    - name: "node-ip"
      value: "${CONTROL_PLANE_IP}"
    - name: "kube-reserved"
      value: "${KUBE_RESERVED}"
    - name: "system-reserved"
      value: "${SYSTEM_RESERVED}"
    - name: "eviction-hard"
      value: "${EVICTION_HARD}"
localAPIEndpoint:
  advertiseAddress: "${CONTROL_PLANE_IP}"
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
clusterName: "${CLUSTER_NAME}"
kubernetesVersion: "${KUBERNETES_VERSION}"
controlPlaneEndpoint: "${CONTROL_PLANE_ENDPOINT}"
networking:
  dnsDomain: "cluster.local"
  serviceSubnet: "${SERVICE_SUBNET}"
  podSubnet: "${POD_SUBNET}"
apiServer:
  certSANs:
$(for san in ${API_SERVER_CERT_SANS:-${CONTROL_PLANE_ENDPOINT%%:*} ${CONTROL_PLANE_IP}}; do printf "    - \"%s\"\n" "$san"; done)
EOF

kubeadm init --config /tmp/bizkit-kubeadm-init.yaml

mkdir -p "${HOME}/.kube"
cp /etc/kubernetes/admin.conf "${HOME}/.kube/config"
chown "$(id -u):$(id -g)" "${HOME}/.kube/config"

log "Control plane initialized."
log "Next commands:"
log "  kubeadm token create --print-join-command"
log "  kubeadm init phase upload-certs --upload-certs"
