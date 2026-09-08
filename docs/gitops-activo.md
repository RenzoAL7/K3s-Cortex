# GitOps de GPath

## Estado observado

Verificado el 7 de septiembre de 2026 a las 16:24 UTC en `OCI_VM`:

- Argo CD v3.5.2 ya estaba instalado. Se registró `gpath-prod` usando
  `clusters/rnz-prod/gpath-application.yaml`; no fue necesario reinstalarlo.
- Application `gpath-prod`: `Synced` / `Healthy`, namespace destino `gpath`.
- Origen: `RenzoAL7/K3s-Cortex`, rama `main`, overlay `apps/gpath/overlays/growth`.
- Primera sincronización automática completada contra
  `e760505c75d8306866da52161a4cc4b1f943ad7a`, tras la promoción revisada en PR #14.
- Web y API: dos réplicas cada una, imágenes GHCR fijadas por digest. Se sustituyeron
  las imágenes demo importadas manualmente en containerd.
- Smoke público aprobado: web y API con build `12f7b19`, modo `demo`.
- Ingress `gpath` y `gpath-lb-health`: dirección publicada `193.122.221.201`.

Son observaciones puntuales, no una garantía de disponibilidad. Los datos siguen
siendo doce ofertas ficticias. No se activó la Application raíz.

## Publicar un cambio

```text
PR en GPath → revisión y merge del propietario
  → CI: pruebas y publicación de web + API
  → PR automática de promoción en Cortex con ambos digests
  → revisión y merge del propietario
  → Argo CD sincroniza GPath → comprobar la web pública
```

La configuración habilita `prune` y `selfHeal`: Argo compara lo declarado en Git
con los recursos de GPath. No hay merge automático. Una PR abierta de interfaz
no cambia la web pública y una compilación correcta no demuestra un despliegue.

Para volver a una versión anterior, preparar una PR que revierta la promoción
de ambos digests en Cortex. Revisarla, fusionarla y repetir las comprobaciones.
La reversión y la recuperación frente a cambios manuales no se ensayaron en vivo
durante esta activación.

## Por qué el Ingress ya aparece Healthy

Traefik recibe tráfico por el LB OCI existente, pero su Service es `ClusterIP`.
No había una dirección externa del Service que publicar en el estado del Ingress;
Argo mostraba `Progressing` aunque la web respondía.

`infra/oci-vm/traefik-config.yaml` desactiva `publishedService` y configura
`providers.kubernetesIngress.ingressEndpoint.ip` con la IP real del LB,
`193.122.221.201`. Traefik ahora publica esa dirección. No se sobrescribió la
evaluación de salud de Argo ni se inventó un estado Healthy. Si cambia la IP del
LB, actualizar esta configuración también.

El archivo se instaló en la VM como
`/var/lib/rancher/k3s/server/manifests/traefik-config.yaml`. El respaldo previo está
en `/home/opc/cortex-setup/traefik-config-before-status.yaml`. Reaplicarlo conserva
el acceso público anterior, pero deja de anunciar la dirección del Ingress.

Esta configuración de Traefik y el bootstrap son pasos de plataforma manuales
versionados: **no están reconciliados por la Application de GPath**. El LB y el
firewall tampoco los administra Argo. Es una VM única, no alta disponibilidad;
actualizar Traefik con `Recreate` puede interrumpir brevemente el tráfico.

## Comprobar sin modificar recursos

Dentro de la VM:

```bash
sudo /usr/local/bin/k3s kubectl -n argocd get applications
sudo /usr/local/bin/k3s kubectl -n gpath get deployments,pods,services,ingress
sudo /usr/local/bin/k3s kubectl -n argocd get application gpath-prod \
  -o jsonpath='{.status.sync.revision}{"\n"}{.status.operationState.phase}{"\n"}'
```

Desde el repo GPath en el Mac:

```bash
SMOKE_BASE_URL=https://gpath.tech node scripts/smoke.mjs
```

El health check `/healthz` del LB verifica la web. El smoke también comprueba la
API y la coincidencia del build de ambos contenedores. Argo CD permanece privado;
no se abrió un endpoint administrativo público para esta activación.
