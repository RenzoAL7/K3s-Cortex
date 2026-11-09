# rnz-prod

Raíz declarativa del clúster K3s en OCI.

La Application raíz `cortex-root` registra las aplicaciones declaradas en esta
carpeta mediante el patrón app-of-apps:

- `gpath-prod`: Growth Path, la exploración de requisitos de vacantes.
- `brinke-prod`: frontend móvil de Brinke.
- `peru-budget-prod`: plataforma de datos del gasto público del Perú.
