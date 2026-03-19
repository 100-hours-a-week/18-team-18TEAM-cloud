#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl kustomize "$ROOT/k8s/platform/base/networking/calico"
