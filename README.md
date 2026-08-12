# K3s-Cortex

Infraestructura como código para administrar un clúster K3s mediante GitOps.

---

## Objetivo

Centralizar la configuración del clúster, sus componentes de plataforma y los
despliegues futuros de forma declarativa, versionada y auditable.

---

## Alcance

- Bootstrap de Argo CD.
- Configuración de namespaces, RBAC e ingreso de tráfico con Traefik.
- Despliegues de GitPath y Cluster Signal gestionados por Argo CD.
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
├── platform/            # Componentes compartidos: ingress, seguridad y observabilidad
├── apps/                # Despliegues de aplicaciones
├── docs/                # Decisiones y documentación técnica
└── README.md
```

Cada aplicación mantiene una base reutilizable y un overlay de producción con
imágenes fijadas a commits inmutables.

---

## Convenciones

- `main` representa el estado deseado del clúster.
- Todo cambio se realiza en una rama y llega a `main` mediante Pull Request.
- Los manifiestos deben ser declarativos y reproducibles.
- Nunca se suben secretos, kubeconfig, claves SSH ni archivos de entorno reales.

---

## Aplicaciones

- `apps/gitpath`: experiencia web para aprender Git.
- `apps/cluster-signal`: dashboard AIOps con observación Kubernetes de solo
  lectura y detección local de anomalías.
