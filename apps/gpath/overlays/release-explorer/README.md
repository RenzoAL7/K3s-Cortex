# Overlay preparado, todavía inactivo

Este overlay añade la API de GPath y el enrutamiento `/api`. No lo apliques
con `release-not-published`: las imágenes nuevas todavía no están referenciadas.

Publicar esta carpeta y `apps/gpath/api` **no cambia** la Application existente,
que sigue leyendo `apps/gpath/overlays/prod`.

La primera PR de promoción generada por GPath fija los digests reales de web/API
y cambia `clusters/rnz-prod/gpath-application.yaml` al nuevo path en un mismo commit.
Revisa esa PR antes de integrarla. No se modifica el load balancer OCI.

Validación offline: `kubectl kustomize apps/gpath/overlays/release-explorer`.
La API usa otro selector para no entrar en el Service del frontend. No requiere
base de datos, PVC o permisos sobre la API de Kubernetes. Un Secret `gpath-archive`
con clave `catalog-url` permite conectar un catálogo OCI, pero es opcional y no
se guarda en este repo.
