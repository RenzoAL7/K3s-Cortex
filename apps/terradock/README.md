# TerraDock: portada pública

Este directorio despliega únicamente el frontend estático de `RenzoAL7/TerraDock`. No publica el servidor Go, el editor local ni APIs de archivos. Código e imagen: rama `codex/landing-publica` y paquete público `ghcr.io/renzoal7/terradock-public`.

El overlay `overlays/ip` se sirve inicialmente en **http://193.122.221.201/**. No configura TLS ni un dominio de TerraDock. La ruta sin host usa prioridad 1 para conservar la precedencia del host `gpath.tech` y del chequeo exacto `/healthz` del balanceador.

## Aplicación independiente

- Argo CD: `terradock-public`, rama `codex/terradock-publica`, ruta `apps/terradock/overlays/ip`.
- Namespace: `terradock`; Service interno en 80 y contenedor en 8080.
- Dos réplicas en el nodo ARM64 existente, sin tolerancia a la pérdida de la VM.
- Imagen fijada por digest, no por `latest`; GHCR debe permitir descarga pública.
- UID/GID 101, raíz de solo lectura, `/tmp` temporal, sin token de ServiceAccount, sin capabilities y con seccomp RuntimeDefault.
- NetworkPolicy: entrada de Traefik y ninguna salida; cuotas limitadas al namespace nuevo.

Validar antes de aplicar:

```sh
kubectl kustomize apps/terradock/overlays/ip
```

Registrar **solo** `clusters/rnz-prod/terradock-application.yaml` en Argo CD. No es necesario reaplicar `gpath-application.yaml` ni modificar el balanceador OCI. Argo CD crea y mantiene los recursos del overlay.

Después comprobar `Synced / Healthy`, dos pods listos, la imagen por digest y el contenido de `/release.json` por la IP. La guía de pruebas HTTP y navegador está en `TerraDock/docs/public-deployment.md`.

## Actualizar o retirar

Una nueva versión requiere un workflow satisfactorio en TerraDock y cambiar el digest en `overlays/ip/kustomization.yaml`. Publicar esa revisión de Cortex dispara la sincronización de Argo CD. Para revertir, recuperar el digest previo en Git.

Para retirar la portada, eliminar únicamente la aplicación Argo CD `terradock-public` con sus recursos mediante su finalizer y luego retirar sus manifiestos/referencia de Git. No tocar los recursos de GPath, Traefik ni OCI.
