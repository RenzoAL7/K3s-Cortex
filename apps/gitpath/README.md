# GitPath deployment

This directory contains the Argo CD child application and the production
manifests for the GitPath frontend.

The production overlay pins the public GHCR image to a full commit SHA. A
future promotion changes only `newTag` in the overlay, then Argo CD detects
the Git change and rolls out the new image.

The application uses a `ClusterIP` service and a Traefik `Ingress`. Public
traffic will be added later through the OCI Load Balancer, keeping the K3s
node private.
