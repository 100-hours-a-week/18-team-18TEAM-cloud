#!/usr/bin/env bash

set -euo pipefail

KUBECTL="sudo KUBECONFIG=/etc/kubernetes/admin.conf kubectl"

NODE="${1:?node name is required}"

$KUBECTL uncordon "${NODE}"
$KUBECTL get node "${NODE}"
