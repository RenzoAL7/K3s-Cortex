# rnz-prod

Raíz declarativa del clúster K3s en OCI.

La Application raíz `cortex-root` registra las aplicaciones declaradas en esta
carpeta mediante el patrón app-of-apps:

- `gpath-prod`: Growth Path, la exploración de requisitos de vacantes.
- `brinke-prod`: frontend móvil de Brinke.
- `peru-budget-prod`: plataforma de datos del gasto público del Perú.
- `portafolio-prod`: sitio personal en `renzoaguilar.dev`. Cada push a `main` de
  `RenzoAL7/portafolio` publica una imagen y escribe su digest en el overlay `prod`.
- `terradock-public`: portada de TerraDock en `terradock.renzoaguilar.dev` y en la
  ruta general `/` de la IP del balanceador.
