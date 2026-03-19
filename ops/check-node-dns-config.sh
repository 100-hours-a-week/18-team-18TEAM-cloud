#!/usr/bin/env bash
set -euo pipefail

echo "=== hostname ==="
hostname

echo "=== /etc/resolv.conf ==="
cat /etc/resolv.conf || true

echo "=== /run/systemd/resolve/resolv.conf ==="
cat /run/systemd/resolve/resolv.conf || true

echo "=== /run/systemd/resolve/stub-resolv.conf ==="
cat /run/systemd/resolve/stub-resolv.conf || true

echo "=== resolvectl status ==="
resolvectl status || true

echo "=== direct lookup via default resolver: mysql ==="
timeout 5 getent ahostsv4 mysql.prod.bizkit.private || true

echo "=== direct lookup via default resolver: redis ==="
timeout 5 getent ahostsv4 redis.prod.bizkit.private || true

echo "=== direct lookup via node-local-dns 169.254.20.10: mysql ==="
timeout 5 nslookup mysql.prod.bizkit.private 169.254.20.10 || true

echo "=== direct lookup via node-local-dns 169.254.20.10: redis ==="
timeout 5 nslookup redis.prod.bizkit.private 169.254.20.10 || true

echo "=== direct lookup via first nameserver in /etc/resolv.conf: mysql ==="
NS="$(awk '/^nameserver / {print $2; exit}' /etc/resolv.conf || true)"
if [[ -n "${NS}" ]]; then
  timeout 5 nslookup mysql.prod.bizkit.private "${NS}" || true
fi

echo "=== direct lookup via first nameserver in /etc/resolv.conf: redis ==="
if [[ -n "${NS}" ]]; then
  timeout 5 nslookup redis.prod.bizkit.private "${NS}" || true
fi
