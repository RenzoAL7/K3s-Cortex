#!/usr/bin/env bash
# Ejecutar en la VM: sudo bash install-k3s.sh
set -euo pipefail
[[ "$EUID" -eq 0 ]] || { echo 'Ejecuta con sudo.' >&2; exit 1; }
[[ "$(uname -m)" == aarch64 ]] || { echo 'Esta receta está preparada para la VM ARM.' >&2; exit 1; }
recipe_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ -x /usr/local/bin/k3s ]]; then
  echo 'k3s ya está instalado; no se sobrescribe ni actualiza automáticamente.'
  /usr/local/bin/k3s --version
  exit 0
fi
install -d -m 700 /etc/rancher/k3s
[[ ! -e /etc/rancher/k3s/config.yaml ]] || { echo 'Ya existe config.yaml; revisa antes de instalar.' >&2; exit 1; }
install -m 600 "$recipe_dir/k3s-config.yaml" /etc/rancher/k3s/config.yaml
install -d -m 755 /var/lib/rancher/k3s/server/manifests
install -m 600 "$recipe_dir/traefik-config.yaml" /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
if systemctl is-active --quiet firewalld; then
  # Únicamente las redes internas de pods/servicios. No se abre ningún puerto público.
  for network in 10.42.0.0/16 10.43.0.0/16; do
    firewall-cmd --permanent --zone=trusted --add-source="$network"
    firewall-cmd --zone=trusted --add-source="$network"
  done
fi
installer=$(mktemp /tmp/cortex-k3s-installer.XXXXXX)
trap 'rm -f "$installer"' EXIT
curl --fail --silent --show-error --location --retry 3 https://get.k3s.io -o "$installer"
# Versión fijada, consultada en el canal stable el 2026-09-06.
INSTALL_K3S_VERSION='v1.36.4+k3s1' sh "$installer"
/usr/local/bin/k3s kubectl wait --for=condition=Ready node --all --timeout=180s
/usr/local/bin/k3s kubectl get nodes -o wide
echo 'Instalación terminada. No compartas /etc/rancher/k3s/k3s.yaml ni el token del servidor.'
