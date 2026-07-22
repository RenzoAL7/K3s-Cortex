# Bootstrap de Argo CD

Este directorio contiene el punto de arranque manual de GitOps. La instalación
de Argo CD se aplica una sola vez; después, `root-application.yaml` hace que
Argo CD sincronice el estado deseado desde este repositorio.

## Precondición

No ejecutar estos comandos hasta haber retirado la instalación antigua de Argo
CD y sus aplicaciones heredadas del clúster.

## Instalación inicial

Desde la VM, con acceso administrativo a K3s:

```bash
sudo /usr/local/bin/k3s kubectl create namespace argocd
sudo /usr/local/bin/k3s kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.4.2/manifests/install.yaml
```

Cuando todos los pods de Argo CD estén listos, aplicar la Application raíz:

```bash
sudo /usr/local/bin/k3s kubectl apply -k bootstrap/
```

## Resultado

Argo CD observará `clusters/rnz-prod` en la rama `main`. Los cambios futuros
se harán mediante Pull Requests y no con `kubectl apply` manual sobre las
aplicaciones.
