#!/usr/bin/env bash
set -euo pipefail

CP_HOST="ktb-prod-k8s-cp"
DB_URL="${1:-jdbc:mysql://mysql.dev.bizkit.private:3306/caro}"
REDIS_HOST="${2:-redis.dev.bizkit.private}"

DB_URL_B64="$(printf '%s' "${DB_URL}" | base64)"
REDIS_HOST_B64="$(printf '%s' "${REDIS_HOST}" | base64)"

ssh -o BatchMode=yes -o ConnectTimeout=8 "${CP_HOST}" \
  "sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n dev patch secret be-secret --type merge -p '{\"data\":{\"SPRING_DATASOURCE_URL\":\"${DB_URL_B64}\",\"REDIS_HOST\":\"${REDIS_HOST_B64}\"}}' >/dev/null && \
   sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n dev get secret be-secret -o jsonpath='{.data.SPRING_DATASOURCE_URL}' | base64 -d && echo && \
   sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n dev get secret be-secret -o jsonpath='{.data.REDIS_HOST}' | base64 -d && echo"
