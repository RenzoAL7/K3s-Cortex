# Cluster Signal deployment

This directory deploys the Cluster Signal web dashboard and read-only AIOps
API. The production overlay pins both public GHCR images to the same immutable
source commit.

Traefik serves the application at `/cluster-signal/`. A strip-prefix middleware
keeps the application containers independent of the external route. The API
service account can only read pods, events, namespaces, and pod metrics; it has
no mutation verbs and no access to Secrets.

The OCI model bucket remains private. Production therefore starts with the
deterministic hashing backend until a scoped authenticated download mechanism
is configured. This state is visible at `/cluster-signal/ready`.
