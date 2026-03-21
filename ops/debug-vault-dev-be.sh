#!/usr/bin/env bash
set -euo pipefail

ROOT_TOKEN_FILE="$(
  ls -1 /root/vault-init-*.txt /home/ubuntu/vault-init-*.txt 2>/dev/null | head -n 1 || true
)"

if [ -z "${ROOT_TOKEN_FILE}" ]; then
  echo "no root token file found" >&2
  exit 1
fi

ROOT_TOKEN="$(
  grep -m1 '^Initial Root Token:' "${ROOT_TOKEN_FILE}" | awk '{print $4}'
)"

if [ -z "${ROOT_TOKEN}" ]; then
  echo "failed to extract root token" >&2
  exit 1
fi

export VAULT_ADDR="https://10.0.255.98:8200"
export VAULT_CACERT="/etc/vault.d/tls/vault.crt"

VAULT_TOKEN="${ROOT_TOKEN}" vault kv get -format=json secret/dev/be \
  | jq -r '
      "version=" + (.data.metadata.version|tostring),
      "keys=" + ((.data.data|keys)|join(",")),
      "SPRING_DATASOURCE_URL=" + .data.data.SPRING_DATASOURCE_URL,
      "REDIS_HOST=" + .data.data.REDIS_HOST,
      "AI_SERVER_URL=" + .data.data.AI_SERVER_URL
    '
