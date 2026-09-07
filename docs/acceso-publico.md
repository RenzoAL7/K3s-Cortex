# Demo pública: OCI Load Balancer → Traefik

Este documento registra la exposición inicial. Desde el 7 de septiembre de 2026,
GPath usa Argo CD y el overlay `growth` con imágenes por digest. Consulta
[GitOps activo](gitops-activo.md); no reapliques `public-demo` sobre la aplicación
gestionada por Argo CD, porque volvería a las imágenes locales antiguas.

## Configuración

El balanceador existente `lb-rnz-prod-edge` conserva sus listeners 80/443 y su
certificado de origen. Su único backend sigue siendo `10.0.1.232:80`.
El health check HTTP pasa de `/` a `/healthz`, esperando HTTP 200.

`infra/oci-vm/traefik-config.yaml` utiliza `service.spec.type: ClusterIP`, compatible
con el chart instalado 40.1.4+up40.1.0. `service.type` era ignorado por esta versión.
El entrypoint web expone `hostPort: 80`; el firewall permite ese puerto desde
`10.0.0.0/24`, la subred del LB. Las listas de seguridad OCI existentes ya permiten
ese recorrido. La VM permanece privada; no se abre Kubernetes ni Argo CD al público.

La estrategia `Recreate` evita que dos pods Traefik compitan por el mismo hostPort.
En esta VM única una actualización de Traefik tiene una breve interrupción: no HA.
No se exponen por hostPort el dashboard, métricas ni el puerto TLS interno de Traefik.

Cloudflare → TLS al LB OCI → HTTP privado a Traefik → web/API.
El último tramo privado no usa TLS; no afirmar cifrado extremo a extremo.

`apps/gpath/overlays/public-demo` usa las imágenes demo importadas y el host
`gpath.tech`. El Ingress de salud acepta únicamente `/healthz` sin exigir Host;
comprueba la web, no la disponibilidad completa de la API. Las pruebas públicas
de `/api/jobs` complementan ese health check.

## Reproducir los cambios del clúster

En el Mac, copiar la configuración de Traefik a la VM y luego instalarla en
`/var/lib/rancher/k3s/server/manifests/traefik-config.yaml`. Para una VM ya instalada,
guardar primero una copia de la configuración anterior. Aplicar el overlay:

```bash
kubectl kustomize apps/gpath/overlays/public-demo | ssh OCI_VM \
  'sudo /usr/local/bin/k3s kubectl apply -f -'
```

En la VM, regla runtime y persistente:

```bash
sudo firewall-cmd --add-rich-rule='rule family=ipv4 source address=10.0.0.0/24 port port=80 protocol=tcp accept'
sudo firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=10.0.0.0/24 port port=80 protocol=tcp accept'
```

En OCI, editar únicamente el health check del backend set existente a HTTP,
puerto 80, ruta `/healthz`, respuesta 200. No crear un segundo balanceador.

## Comprobar y revertir

Verificado el 7 de septiembre de 2026 a las 01:05 UTC: los dos health checks del
backend indicaron `OK`. El smoke test de web y API sobre `https://gpath.tech` pasó.

```bash
curl --fail https://gpath.tech/healthz
curl --fail 'https://gpath.tech/api/jobs?role=data'
```

Para volver a acceso privado: aplicar `growth-demo`, quitar `ports.web.hostPort`
del HelmChartConfig y retirar las dos reglas de firewall anteriores usando
`--remove-rich-rule`. Esto dejará deliberadamente sin servicio al LB público.
El respaldo previo de Traefik está en la VM en
`/home/opc/cortex-setup/traefik-config-before-public.yaml`; tenía el campo antiguo
`service.type`, por lo que debe corregirse a `service.spec.type` al reutilizarlo.

La exposición inicial no activaba GitOps. Ese paso se completó después de revisar
las PRs y publicar los digests reales; el registro actual está en `gitops-activo.md`.
