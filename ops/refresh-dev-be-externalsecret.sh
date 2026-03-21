#!/usr/bin/env bash
set -euo pipefail

CP_HOST="ktb-prod-k8s-cp"
STAMP="$(date +%s)"

ssh -o BatchMode=yes -o ConnectTimeout=8 "${CP_HOST}" \
  "sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n dev annotate externalsecret be-secret force-sync=${STAMP} --overwrite >/dev/null && \
   sleep 5 && \
   sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n dev get secret be-secret -o jsonpath='{.data.SPRING_DATASOURCE_URL}' | base64 -d && echo && \
   sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n dev get secret be-secret -o jsonpath='{.data.REDIS_HOST}' | base64 -d && echo"
