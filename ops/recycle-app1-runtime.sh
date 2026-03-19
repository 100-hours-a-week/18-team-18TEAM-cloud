#!/usr/bin/env bash
set -euo pipefail

echo "=== before ==="
systemctl is-active systemd-resolved || true
systemctl is-active crio || true
systemctl is-active kubelet || true

echo "=== restarting systemd-resolved ==="
sudo systemctl restart systemd-resolved
sleep 2

echo "=== restarting crio ==="
sudo systemctl restart crio
sleep 3

echo "=== restarting kubelet ==="
sudo systemctl restart kubelet
sleep 10

echo "=== after ==="
systemctl is-active systemd-resolved
systemctl is-active crio
systemctl is-active kubelet

echo "=== node resolvectl ==="
resolvectl status || true
