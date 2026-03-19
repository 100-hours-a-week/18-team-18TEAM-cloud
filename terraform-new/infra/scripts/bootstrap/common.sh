#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    fail "Run this script as root or with sudo."
  fi
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    fail "Required environment variable is missing: ${name}"
  fi
}

load_env_file() {
  local env_file="${1:-/etc/bizkit/bootstrap.env}"
  if [[ -f "${env_file}" ]]; then
    # shellcheck disable=SC1090
    source "${env_file}"
  fi
}

set_node_hostname() {
  local hostname_value="$1"
  if [[ -n "${hostname_value}" ]]; then
    hostnamectl set-hostname "${hostname_value}"
  fi
}

disable_swap() {
  swapoff -a || true
  sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
}

configure_kernel() {
  cat >/etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

  modprobe overlay
  modprobe br_netfilter

  cat >/etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

  sysctl --system
}

install_base_packages() {
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl git golang-go gpg jq software-properties-common
}

install_kubernetes_packages() {
  local kubernetes_minor="${1:-v1.33}"

  mkdir -p /etc/apt/keyrings
  curl -fsSL "https://pkgs.k8s.io/core:/stable:/${kubernetes_minor}/deb/Release.key" \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  cat >/etc/apt/sources.list.d/kubernetes.list <<EOF
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${kubernetes_minor}/deb/ /
EOF

  apt-get update
  apt-get install -y kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl
}

install_crio() {
  local kubernetes_minor="${1:-v1.33}"

  mkdir -p /etc/apt/keyrings
  curl -fsSL "https://download.opensuse.org/repositories/isv:/cri-o:/stable:/${kubernetes_minor}/deb/Release.key" \
    | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

  cat >/etc/apt/sources.list.d/cri-o.list <<EOF
deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/${kubernetes_minor}/deb/ /
EOF

  apt-get update
  apt-get install -y cri-o
  systemctl enable crio
  systemctl restart crio
  systemctl disable --now containerd 2>/dev/null || true
}

write_kubelet_defaults() {
  mkdir -p /etc/bizkit

  cat >/etc/bizkit/kubelet-defaults.env <<EOF
KUBE_RESERVED="${KUBE_RESERVED:-cpu=150m,memory=400Mi,ephemeral-storage=1Gi}"
SYSTEM_RESERVED="${SYSTEM_RESERVED:-cpu=150m,memory=600Mi,ephemeral-storage=1Gi}"
EVICTION_HARD="${EVICTION_HARD:-memory.available<500Mi,nodefs.available<10%,imagefs.available<15%,nodefs.inodesFree<5%}"
ECR_CREDENTIAL_PROVIDER_VERSION="${ECR_CREDENTIAL_PROVIDER_VERSION:-v1.33.3}"
EOF
}

install_ecr_credential_provider() {
  local provider_version="${ECR_CREDENTIAL_PROVIDER_VERSION:-v1.33.3}"

  mkdir -p /opt/ecr-credential-provider/bin /etc/kubernetes/image-credential-provider

  GOBIN=/opt/ecr-credential-provider/bin \
    GO111MODULE=on \
    GOPROXY=https://proxy.golang.org,direct \
    CGO_ENABLED=0 \
    go install "k8s.io/cloud-provider-aws/cmd/ecr-credential-provider@${provider_version}"

  cat >/etc/kubernetes/image-credential-provider/ecr-credential-provider.yaml <<'EOF'
apiVersion: kubelet.config.k8s.io/v1
kind: CredentialProviderConfig
providers:
- name: ecr-credential-provider
  matchImages:
  - "*.dkr.ecr.*.amazonaws.com"
  - "*.dkr.ecr.*.amazonaws.com.cn"
  - "*.dkr.ecr-fips.*.amazonaws.com"
  defaultCacheDuration: "12h"
  apiVersion: credentialprovider.kubelet.k8s.io/v1
EOF

  cat >/etc/default/kubelet <<'EOF'
KUBELET_EXTRA_ARGS="--image-credential-provider-config=/etc/kubernetes/image-credential-provider/ecr-credential-provider.yaml --image-credential-provider-bin-dir=/opt/ecr-credential-provider/bin"
EOF
}

ensure_control_plane_endpoint_mapping() {
  local endpoint_ip="${CONTROL_PLANE_ENDPOINT_IP:-}"
  local endpoint_dns="${CONTROL_PLANE_ENDPOINT_DNS:-}"

  if [[ -n "${endpoint_ip}" && -n "${endpoint_dns}" ]]; then
    sed -i "\|[[:space:]]${endpoint_dns}$|d" /etc/hosts
    printf '%s %s\n' "${endpoint_ip}" "${endpoint_dns}" >>/etc/hosts
  fi
}

bootstrap_common_node() {
  require_root

  log "Disabling swap"
  disable_swap

  log "Configuring kernel modules and sysctl"
  configure_kernel

  log "Installing base packages"
  install_base_packages

  log "Installing Kubernetes packages"
  install_kubernetes_packages "${KUBERNETES_APT_CHANNEL:-v1.33}"

  log "Installing and enabling CRI-O"
  install_crio "${KUBERNETES_APT_CHANNEL:-v1.33}"

  log "Writing kubelet defaults"
  write_kubelet_defaults

  log "Installing kubelet ECR credential provider"
  install_ecr_credential_provider

  log "Enabling kubelet"
  systemctl daemon-reload
  systemctl enable kubelet

  log "Bootstrap common node step completed"
}
