# Verificación de la primera demo

Comprobación realizada el 6 de septiembre de 2026 (hora de Lima).

Este registro describe la instalación inicial. Posteriormente se migró el namespace
`gitpath` a `gpath`; consulta `migracion-gpath.md` para los nombres y pruebas actuales.

## Resultado observado

- VM `OCI_VM`, nodo `ocivm`: `Ready`, k3s `v1.36.4+k3s1`.
- Argo CD `v3.5.2`: sus siete pods `Running`, todos `1/1`.
- Namespace `gitpath`: web y API `Running`, `1/1`, sin reinicios en la comprobación.
- SELinux permanece `Enforcing`; no se configuró acceso público nuevo.
- Muestra puntual de `kubectl top nodes`: 73m de CPU y 1893 MiB de memoria.
  No es una prueba de carga ni una garantía de capacidad.

## Recorrido probado

Navegador en el Mac → túnel SSH/Bastion → Traefik → Service → web/API.

La demo está disponible en `http://localhost:18080` mientras el túnel siga abierto
y la sesión Bastion sea válida. La guía `primer-despliegue.md` explica cómo reabrirlo.

- `npm test`: 19 pruebas locales aprobadas.
- `npm run build`: compilación aprobada.
- Imágenes ARM64 de web y API: construidas e importadas en containerd de la VM.
- `SMOKE_BASE_URL=http://localhost:18080 node scripts/smoke.mjs`: aprobado contra
  la VM; comprueba web, API, cabeceras y coincidencia de metadatos de construcción.
- `E2E_BASE_URL=http://localhost:18080 npm run test:e2e`: 8 pruebas aprobadas contra
  la VM, en escritorio y móvil, incluyendo selección de roles y errores simulados.
- Capturas de escritorio y móvil inspeccionadas; prueba adicional sin desbordamiento
  horizontal a 320 px.
- `git diff --check`: aprobado en ambos repositorios.

## Límites explícitos

Esta es una **demo manual**, no una promoción GitOps completada. Las imágenes
`gpath-web:demo-v1` y `gpath-api:demo-v1` se importaron localmente. El código contiene
cambios sin commit; el identificador de revisión incluido no representa por sí solo
todo el contenido de estas imágenes.

No se han publicado commits, PRs ni imágenes en el registro. Argo CD todavía no
reconcilia GPath desde Cortex. No se aplicó la Application raíz.

Los datos son doce ofertas ficticias, claramente identificadas en la página. La
recolección de ofertas reales, el bucket, el Load Balancer, TLS público y los backups
siguen pendientes. La aplicación no usa Supabase ni una base relacional.

El siguiente hito es publicar los cambios revisados, promover los dos digests mediante
PR en Cortex, comprobar `Synced` / `Healthy` y demostrar una reversión.
