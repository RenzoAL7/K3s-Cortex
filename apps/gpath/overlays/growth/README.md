# Growth Path

Web + API en el namespace `gpath`, con recursos `gpath` y `gpath-api`.
Las imágenes GHCR conservan sus direcciones existentes para no mover paquetes.

No aplicar este overlay con `release-not-published`: primero la CI de GPath publica
las dos imágenes y abre un PR con sus digests. Al fusionarlo, Argo CD aplica el cambio.
Revertir ese PR permite volver a la versión anterior.

La demo local en `../growth-demo` usa imágenes importadas, no publicadas. Es una
comprobación manual del runtime, NO una demostración de GitOps completado.
