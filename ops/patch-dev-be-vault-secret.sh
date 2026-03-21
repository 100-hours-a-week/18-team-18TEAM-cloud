#!/usr/bin/env bash
set -euo pipefail

DB_URL="${1:-jdbc:mysql://mysql.dev.bizkit.private:3306/caro}"
REDIS_HOST="${2:-redis.dev.bizkit.private}"

CP_HOST="ktb-prod-k8s-cp"
VAULT_HOST="ktb-vault"
VAULT_ADDR="https://10.0.255.98:8200"
VAULT_CACERT="/etc/vault.d/tls/vault.crt"
VAULT_ROLE="bizkit-prod-cluster-external-secrets-role"
VAULT_PATH="secret/dev/be"

JWT="$(
  ssh -o BatchMode=yes -o ConnectTimeout=8 "${CP_HOST}" \
    'sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n system create token external-secrets --duration=10m'
)"

ssh -o BatchMode=yes -o ConnectTimeout=8 "${VAULT_HOST}" \
  sudo env \
    JWT="${JWT}" \
    VAULT_ADDR="${VAULT_ADDR}" \
    VAULT_CACERT="${VAULT_CACERT}" \
    VAULT_ROLE="${VAULT_ROLE}" \
    VAULT_PATH="${VAULT_PATH}" \
    bash -s -- "${DB_URL}" "${REDIS_HOST}" <<'EOF'
set -euo pipefail

DB_URL="$1"
REDIS_HOST_VALUE="$2"

patch_with_token() {
  local token="$1"
  if ! VAULT_TOKEN="${token}" vault kv patch "${VAULT_PATH}" \
    SPRING_DATASOURCE_URL="${DB_URL}" \
    REDIS_HOST="${REDIS_HOST_VALUE}" >/dev/null; then
    return 1
  fi
  VAULT_TOKEN="${token}" vault kv get -format=json "${VAULT_PATH}" \
    | jq -r '.data.data.SPRING_DATASOURCE_URL,.data.data.REDIS_HOST'
}

TOKEN="$(vault write -field=token auth/kubernetes/login role="${VAULT_ROLE}" jwt="${JWT}" 2>/dev/null || true)"

if [ -n "${TOKEN}" ]; then
  if patch_with_token "${TOKEN}" 2>/dev/null; then
    exit 0
  fi
fi

ROOT_TOKEN_FILE="$(
  ls -1 /root/vault-init-*.txt /home/ubuntu/vault-init-*.txt 2>/dev/null | head -n 1 || true
)"

if [ -z "${ROOT_TOKEN_FILE}" ]; then
  echo "no writable vault token source found" >&2
  exit 1
fi

ROOT_TOKEN="$(
  grep -m1 '^Initial Root Token:' "${ROOT_TOKEN_FILE}" | awk '{print $4}'
)"

if [ -z "${ROOT_TOKEN}" ]; then
  echo "failed to extract root token from ${ROOT_TOKEN_FILE}" >&2
  exit 1
fi

patch_with_token "${ROOT_TOKEN}"
EOF
