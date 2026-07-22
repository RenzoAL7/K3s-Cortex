# K3s-Cortex

Infraestructura como código para administrar un clúster K3s mediante GitOps.

---

## Objetivo

Centralizar la configuración del clúster, sus componentes de plataforma y los
despliegues futuros de forma declarativa, versionada y auditable.

---

## Alcance inicial

- Bootstrap de Argo CD.
- Configuración base de namespaces e ingreso de tráfico.
- Despliegues gestionados desde Git.
- Convenciones para cambios mediante Pull Requests.

---

## Flujo GitOps previsto

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

## Estructura prevista

```text
.
├── bootstrap/           # Instalación inicial y Application raíz de Argo CD
├── clusters/            # Configuración por clúster
├── platform/            # Componentes compartidos: ingress, seguridad y observabilidad
├── apps/                # Despliegues de aplicaciones
├── docs/                # Decisiones y documentación técnica
└── README.md
```

Los directorios se incorporarán progresivamente cuando tengan manifiestos
reales que versionar.

---

## Convenciones

- `main` representa el estado deseado del clúster.
- Todo cambio se realiza en una rama y llega a `main` mediante Pull Request.
- Los manifiestos deben ser declarativos y reproducibles.
- Nunca se suben secretos, kubeconfig, claves SSH ni archivos de entorno reales.

---

## Estado

Repositorio inicializado. El siguiente paso será incorporar el bootstrap limpio
de Argo CD.
