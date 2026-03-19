#!/usr/bin/env bash
set -euo pipefail

echo "=== rebooting node $(hostname) ==="
sudo systemctl reboot
