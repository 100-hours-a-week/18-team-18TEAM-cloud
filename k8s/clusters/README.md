`clusters` is reserved for final cluster entrypoints.

Current rendering is now delegated through `clusters/prod`.

To make `kubectl kustomize k8s/clusters/prod` work under default load restrictions, the prod
entry uses local symlinks to `apps` and `platform` instead of direct upward references.

Responsibility of `clusters`:
- provide one final entrypoint per real cluster environment
- assemble `platform/base` and any cluster-specific platform overlays
- assemble app overlays that belong to that cluster
- separate a real cluster boundary from namespace-based stages inside the cluster

Current target:
- `clusters/prod`: active entrypoint for the current prod cluster
  - prod app overlays only
- `clusters/staging`: active scaffold entrypoint for a dedicated staging cluster
  - staging platform overlays only until app staging overlays are migrated

Planned target:
- migrate app manifests from the current prod/dev split into true `prod/staging` overlays
