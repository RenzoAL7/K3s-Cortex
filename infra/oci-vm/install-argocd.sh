#!/usr/bin/env bash
set -euo pipefail
[[ "$EUID" -eq 0 ]] || { echo 'Ejecuta con sudo.' >&2; exit 1; }
kube=(/usr/local/bin/k3s kubectl)
if "${kube[@]}" -n argocd get deployment argocd-server >/dev/null 2>&1; then
  echo 'Argo CD ya existe; no se actualiza automáticamente.'
  exit 0
fi
manifest=$(mktemp /tmp/cortex-argocd.XXXXXX)
trap 'rm -f "$manifest"' EXIT
curl --fail --silent --show-error --location --retry 3 \
  https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.2/manifests/install.yaml -o "$manifest"
"${kube[@]}" create namespace argocd --dry-run=client -o yaml | "${kube[@]}" apply -f -
"${kube[@]}" apply --server-side -n argocd -f "$manifest"
"${kube[@]}" -n argocd rollout status deployment/argocd-server --timeout=180s
"${kube[@]}" -n argocd get pods
echo 'Argo CD instalado sin IP pública. El repositorio se conectará tras publicar los manifiestos revisados.'
