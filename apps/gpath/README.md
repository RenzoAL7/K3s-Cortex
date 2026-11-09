# GPath deployment

This directory contains the web and API manifests for GPath — Growth Path.
The Argo CD child Application is declared in
`clusters/rnz-prod/gpath-application.yaml` as `gpath-prod`.

The active production overlay is `overlays/growth`, which pins both web and API
by digest. The legacy `prod` overlay retains the earlier frontend image and is not
in use. `overlays/growth-demo` and `overlays/public-demo` run manually imported
ARM64 demo images; do not apply them over the deployment managed by Argo CD.

The application uses `ClusterIP` services and a Traefik `Ingress`. Public traffic
arrives through the OCI Load Balancer, keeping the K3s node private.
