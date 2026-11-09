# K3s-Cortex

Infraestructura como código para administrar un clúster K3s de un solo nodo en
Oracle Cloud mediante GitOps.

Argo CD sincroniza las aplicaciones desde `main` con el patrón app-of-apps: la
Application raíz `cortex-root` registra GPath y Brinke. Ver
[GitOps activo](docs/gitops-activo.md) para el estado verificado, las comprobaciones
y el recorrido de publicación.

---

## Objetivo

Centralizar la configuración del clúster, sus componentes de plataforma y los
despliegues futuros de forma declarativa, versionada y auditable.

---

## Alcance

- Bootstrap de Argo CD.
- Configuración de namespaces, RBAC e ingreso de tráfico con Traefik.
- Despliegues de GPath y Brinke gestionados por Argo CD.
- Recetas de instalación de K3s, Argo CD y Traefik en la VM.
- Convenciones para cambios mediante Pull Requests.

---

## Flujo GitOps

```text
Cambio en infraestructura
        ↓
Pull Request
        ↓
main
        ↓
Argo CD sincroniza el clúster K3s
```

---

## Estructura

```text
.
├── bootstrap/           # Instalación inicial y Application raíz de Argo CD
├── clusters/            # Configuración por clúster
├── apps/                # Despliegues de aplicaciones
├── infra/oci-vm/        # Recetas manuales de K3s, Argo CD y Traefik en la VM
├── docs/                # Decisiones y documentación técnica
└── README.md
```

Cada aplicación mantiene una base reutilizable y un overlay de producción. GPath
fija sus imágenes por digest y Brinke por un tag con el SHA del commit.

---

## Convenciones

- `main` representa el estado deseado del clúster.
- Todo cambio se realiza en una rama y llega a `main` mediante Pull Request.
- Los manifiestos deben ser declarativos y reproducibles.
- Nunca se suben secretos, kubeconfig, claves SSH ni archivos de entorno reales.

---

## Aplicaciones

- `apps/gpath`: Growth Path, exploración de tecnologías presentes en vacantes.
- `apps/brinke`: frontend móvil de Brinke, publicado bajo `/brinke`.

---

## Límites

- Es una sola VM: no hay alta disponibilidad.
- Traefik, Argo CD, el firewall y el balanceador se configuran a mano y Argo CD no
  los reconcilia.
- El backup del estado de K3s y su prueba de restauración siguen pendientes.
