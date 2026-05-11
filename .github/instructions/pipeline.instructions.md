---
applyTo:
  - "pipelines/**"
  - "source_dwh/etl/**"
---

# Pipeline Instructions

Fabric Data Factory pipeline definitions in `pipelines/` follow these rules:

1. Split each domain into at least two pipelines: an initial load and a delta load. Co-locate them under a clear name (e.g., `initial_load_customer.json`, `delta_load_watermark.json`).
2. For transaction-like high-volume tables, design the initial load to partition by date (see `initial_load_transaction_partitioned.json`). Avoid single monolithic copies that exceed pipeline timeouts.
3. Use a watermark column for delta loads. `UPDATED_AT` is the project standard. Document the watermark in the JSON `watermark_column` field.
4. Reference credentials only via Key Vault (`kv-dwh-demo`) or managed identity. Never inline secrets, SAS tokens, or connection strings.
5. Declare the `quality_checks` array on every pipeline, listing the reconciliation SQL the pipeline expects to pass before promoting outputs.
6. Define a `rollback_strategy` paragraph. Default behavior: leave the failing partition empty and surface it in the runbook; do not auto-truncate previously loaded partitions.
7. Use `retry_policy` with exponential backoff for staging-to-warehouse hops. Three attempts is the default.
8. Keep file names ASCII and lowercase with underscores so they sort predictably in the repo.
