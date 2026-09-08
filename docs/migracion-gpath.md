# Migración de nombres a GPath

Realizada el 6 de septiembre de 2026 (Lima).

## Nombres actuales

- Directorio de manifiestos: `apps/gpath/`.
- Namespace: `gpath`.
- Deployments y Services: `gpath` y `gpath-api`.
- Ingress, ServiceAccount y PodDisruptionBudget: `gpath`.
- NetworkPolicy: `gpath-ingress-only`.
- Application declarada en Cortex: `gpath-prod`, en
  `clusters/rnz-prod/gpath-application.yaml`. Todavía no está registrada en Argo CD.

Se actualizaron selectores, etiquetas, backends del Ingress, overlays, documentación,
script de promoción y workflow de GPath. Las direcciones de paquetes GHCR existentes
`ghcr.io/renzoal7/gitpath` y `ghcr.io/renzoal7/gitpath-api` se conservan deliberadamente;
son nombres de imágenes, no nombres de recursos Kubernetes.

## Migración y comprobación

1. Se inventarió `gitpath`: no tenía PVC, secretos de aplicación ni cargas con estado.
2. Se desplegó la misma demo ARM64 en `gpath`, inicialmente con un host de prueba.
3. Se verificaron ambos rollouts y la respuesta de la API a través de Traefik.
4. Se retiró el Ingress anterior y se cambió el nuevo al host `localhost`.
5. Pasó la comprobación HTTP de web y API. Se eliminó el namespace antiguo `gitpath`.
6. Estado final: dos pods `Running`, ambos `1/1`, sin reinicios; 19 pruebas locales y
   8 de navegador aprobadas. No se modificaron Argo CD ni el LB público.

Respaldo local temporal de los recursos anteriores, sin valores de secretos:
`/private/tmp/gpath-rename.PTl2gA/old-gitpath-inventory.txt`.
Es un inventario de recuperación, no un manifiesto listo para aplicar: contiene
metadatos de ejecución que deben limpiarse. Los contenedores antiguos se retiraron;
no se borraron datos persistentes. El directorio temporal puede ser limpiado por el SO.

La verificación utilizó `http://localhost:18082`, con un túnel SSH privado. Para abrir
tu propio túnel en el puerto habitual 18080, consulta `primer-despliegue.md`.

Los cambios de repositorio permanecen locales, sin commit ni push. La demo continúa
siendo manual: este cambio de nombre no equivale a una reconciliación GitOps.

```bash
sudo /usr/local/bin/k3s kubectl -n gpath get deployments,services,ingress
sudo /usr/local/bin/k3s kubectl -n gpath get pods
```
