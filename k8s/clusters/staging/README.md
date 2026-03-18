Active staging-cluster scaffold entrypoint.

This entry:
- assembles `platform/overlays/staging`
- reserves a dedicated cluster boundary for staging-specific platform values
- intentionally stays separate from `clusters/prod`

App overlays remain to be migrated into true `staging` overlays. Until then, this entry is
for staging-cluster platform composition only.

