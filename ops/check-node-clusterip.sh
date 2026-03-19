#!/usr/bin/env bash
set -euo pipefail

echo "=== hostname ==="
hostname

echo "=== TCP 10.96.0.1:443 ==="
timeout 5 bash -lc 'cat < /dev/null > /dev/tcp/10.96.0.1/443' && echo ok || echo fail

echo "=== TCP 10.96.0.10:53 ==="
timeout 5 bash -lc 'cat < /dev/null > /dev/tcp/10.96.0.10/53' && echo ok || echo fail

echo "=== nslookup kubernetes.default.svc.cluster.local @10.96.0.10 ==="
timeout 5 nslookup kubernetes.default.svc.cluster.local 10.96.0.10 || true

echo "=== ip route ==="
ip route || true

echo "=== sysctl bridge/forward ==="
sysctl net.ipv4.ip_forward || true
sysctl net.bridge.bridge-nf-call-iptables || true
sysctl net.bridge.bridge-nf-call-ip6tables || true
