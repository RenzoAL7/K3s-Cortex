# GPath deployment

This directory contains the web and API manifests for GPath — Growth Path.
The Argo CD child Application is declared in
`clusters/rnz-prod/gpath-application.yaml` as `gpath-prod`.

The legacy `prod` overlay retains the earlier frontend image. The first reviewed
promotion pins both web and API by digest in `overlays/growth` and changes the
Application path in the same PR. `overlays/growth-demo` runs the manually imported
ARM64 demo images; it is not a completed GitOps deployment.

The application uses a `ClusterIP` service and a Traefik `Ingress`. Public
traffic will be added later through the OCI Load Balancer, keeping the K3s
node private.
