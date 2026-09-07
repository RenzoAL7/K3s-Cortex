# Tu primera VM con Kubernetes: Growth Path

## Qué hay y qué falta

Actualización: la demo pública usa `apps/gpath/overlays/public-demo` y abre en
https://gpath.tech. Consulta `acceso-publico.md` para la configuración del LB,
Traefik y firewall. Las notas de acceso privado de esta guía siguen siendo útiles
para diagnóstico; no aplicar `growth-demo` sobre la demo pública sin intención de
volver al host `localhost`.

- `infra/oci-vm/`: receta de instalación inicial de k3s y Argo CD.
- `apps/gpath/overlays/growth-demo/`: demo manual con imágenes ARM importadas.
- `apps/gpath/overlays/growth/`: destino de las promociones GitOps por digest.
- `clusters/rnz-prod/gpath-application.yaml`: aplicación Argo CD existente. La
  primera promoción cambia su ruta a `growth`, solo después de publicar ambas imágenes.
- El Load Balancer y TLS público ya permiten acceder a la demo. La recolección
  Greenhouse, bucket y backups son etapas posteriores. La demo NO consulta ofertas
  reales. No afirmar que GitOps funciona
  hasta completar un PR, una reconciliación y una comprobación del resultado.

No necesitas clonar Cortex dentro de la VM. Editamos la copia del Mac, publicamos los
cambios revisados y Argo CD lee GitHub. Para la instalación inicial se copiaron solo
las recetas a `/home/opc/cortex-setup`.

## Las piezas, sin asumir conocimientos

| Pieza | Para qué sirve aquí |
|---|---|
| Nodo | Tu VM; aporta CPU, memoria y disco. |
| k3s | La distribución pequeña de Kubernetes. Incluye el control-plane. |
| API server | Recibe órdenes y cambios declarados mediante `kubectl`. |
| Scheduler y controladores | Eligen dónde ejecutar los pods y mantienen el estado deseado. |
| Kubelet y containerd | Ejecutan y supervisan los contenedores en el nodo. No instalamos Docker en la VM. |
| Pod | La unidad que Kubernetes ejecuta: aquí uno para web y otro para API. |
| Deployment | Indica qué imagen y cuántas copias deben estar funcionando. |
| Service | Nombre y dirección estables para encontrar los pods aunque se reemplacen. |
| Ingress / Traefik | Dirige `/` hacia la web y `/api` hacia la API. |
| Namespace | Agrupa recursos: `gpath`, `argocd`, `kube-system`. |
| Argo CD | Compara los manifiestos en Git con el clúster y los reconcilia. |

La aplicación no usa base relacional. Kubernetes sí necesita su propio almacenamiento
de estado interno; eso es independiente de los datos de Growth Path.

## Primer ejercicio: observar, sin cambiar nada

Dentro de la VM (`ssh OCI_VM`):

```bash
sudo /usr/local/bin/k3s kubectl get nodes
sudo /usr/local/bin/k3s kubectl get pods -A
sudo /usr/local/bin/k3s kubectl -n gpath get deployments,services,ingress
sudo /usr/local/bin/k3s kubectl -n gpath logs deployment/gpath-api --tail=20
sudo /usr/local/bin/k3s kubectl top nodes
```

Busca `Ready` en el nodo y `Running` / `1/1` en los pods. Los jobs de instalación
pueden aparecer `Completed`: terminaron su trabajo, no es un fallo.

## Acceder sin abrir puertos públicos

En una terminal del Mac, mantener abierta:

```bash
ssh -L 18080:127.0.0.1:18080 OCI_VM \
  'sudo /usr/local/bin/k3s kubectl -n kube-system port-forward --address 127.0.0.1 service/traefik 18080:80'
```

En otra terminal del Mac, comprobar el Ingress de la demo:

```bash
curl 'http://localhost:18080/api/jobs?role=data'
```

Abre `http://localhost:18080` para ver la demo que corre en la VM. El overlay demo
usa el host `localhost` para este túnel; la producción conserva `gpath.tech`.

Para Argo CD, otro túnel:

```bash
ssh -L 18081:127.0.0.1:18081 OCI_VM \
  'sudo /usr/local/bin/k3s kubectl -n argocd port-forward --address 127.0.0.1 service/argocd-server 18081:443'
```

Interfaz: `https://localhost:18081` (certificado interno de Argo CD, solo para este
túnel). El usuario inicial es `admin`. Consulta la contraseña únicamente en tu terminal:

```bash
sudo /usr/local/bin/k3s kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

Cámbiala después de entrar. No pegues contraseña, token de k3s ni kubeconfig en el repo
o el chat. La sesión Bastion expira; si el túnel no conecta, ejecuta `bastion-start OCI_VM`.

## La siguiente etapa: activar GitOps de verdad

1. Publicar primero un PR en Cortex con `api`, `growth` y las políticas necesarias.
2. Publicar un PR en GPath con la aplicación, sus pruebas y la CI actualizada.
3. Fusionar GPath: CI construye web y API para ARM64 y abre un PR en Cortex con digests.
4. Revisar y fusionar esa promoción. No hay merge automático de producción.
5. Revisar las aplicaciones incluidas en `bootstrap/root-application.yaml` antes de
   aplicarlo: el root actual también activa `cluster-signal`, que no forma parte de
   esta primera instalación. Alternativa: registrar únicamente la aplicación GPath.
6. Argo CD debe indicar `Synced` y `Healthy`; luego probar `/api/jobs` por el Ingress.
7. Revertir una promoción y comprobar la recuperación con el digest anterior.

No usar `latest` ni hacer `kubectl set image` como sustituto de una promoción GitOps.
El namespace y los recursos se llaman `gpath` y `gpath-api`. La Application se llama
`gpath-prod`. Los paquetes GHCR existentes conservan sus direcciones históricas;
el nombre de una imagen no tiene que coincidir con el de un recurso Kubernetes.

## Operación y límites

La instalación conserva SELinux `Enforcing`, el firewall y kubeconfig modo 0600.
Traefik y Argo CD tienen Services privados. Los logs de contenedores se limitan a
3 archivos de 10 MiB por contenedor. La VM trae swap: no se modifica su configuración
global; el kubelet permite arrancar y los pods mantienen la política NoSwap por defecto.

Una sola VM NO ofrece alta disponibilidad. El bucket de datos no sustituye un backup
del estado de k3s y su token. Pendiente: backup privado y prueba de restauración.

Referencias: [k3s](https://docs.k3s.io/installation/configuration),
[Argo CD](https://argo-cd.readthedocs.io/en/stable/getting_started/).
