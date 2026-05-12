# Copilot Instructions for Fabric DWH Migration Demo

## Project Context
This repository demonstrates migration from an existing IBM PureData / Netezza-style DWH to Microsoft Fabric. All generated code is draft and requires human review. Treat this repository as a migration factory template, not as a production deployment artifact.

## Repository Layout
- `source_dwh/`: Synthetic Netezza-style DDL, views, ETL metadata. Never edit to look like real customer schemas.
- `fabric/DWH_Modernization_Demo.Warehouse/`: Fabric Warehouse item. Fabric Workspace currently serializes this in **SQL Database project format** (`.platform` + `DWH_Modernization_Demo.sqlproj` + `xmla.json`). Earlier per-object layout (`Schemas/dbo/{Tables,Views}/*.sql`) is also accepted by the CI and may be restored by future Fabric versions. The canonical DDL for the demo lives in `fabric/post-deployment/`-style deploy scripts and is applied via SQL editor copy-paste; do not rely on the `.sqlproj` file as the authoring surface.
- `fabric/00_seed_lakehouse.Notebook/`, `fabric/01_load_warehouse.Notebook/`, `fabric/02_validate.Notebook/`: Fabric Notebook items in Git integration format (`.platform` + `notebook-content.py` with `# CELL ********************` / `# MARKDOWN ********************` separators).
- `fabric/post-deployment/`: Security DDL (`CREATE ROLE`, `GRANT`). NOT synced by Fabric Git integration; applied manually via `scripts/reset_demo.sh --security`.
- `fabric/lakehouse/`: Bronze/Silver mapping notes.
- `pipelines/`: Fabric Data Factory pipeline definitions in JSON.
- `tests/`: Reconciliation and quality SQL plus published sample results.
- `api/`: OpenAPI and FastAPI stub that exposes curated Fabric outputs.
- `inventory/`: Object inventory, dependency map, complexity scoring, synthetic sample CSVs.
- `docs/`: Architecture diagram, Copilot prompt cards, SQL dialect mapping, PoC plan.
- `.github/`: Copilot instructions, PR template, workflows, scoped instruction files.

## Azure and Fabric Resources
- Microsoft Fabric Workspace: demo-fabric-dwh-ws
- Fabric Warehouse: wh_dwh_demo
- Fabric Lakehouse / OneLake: lh_dwh_demo
- Fabric Data Factory Pipelines: pl_dwh_migration_demo
- Azure Data Lake Storage Gen2 or Blob staging account: stdwhdemostaging
- Self-hosted Integration Runtime: shir-onprem-dwh-demo
- Azure Key Vault: kv-dwh-demo
- GitHub Repository: fabric-dwh-demo
- GitHub Actions Environments: dev, test, prod

## Migration Rules
- Convert Netezza-style SQL to Fabric Warehouse-compatible T-SQL.
- Preserve numeric precision and scale unless an approved mapping in `docs/sql_dialect_mapping.md` says otherwise.
- Drop Netezza-only clauses (`DISTRIBUTE ON`, `ORGANIZE ON`, `NZ_*` system functions) and document the removal in a SQL comment.
- Map `TIMESTAMP` to `DATETIME2(6)` unless the source clearly stores second precision.
- Quote `Transaction` as `dbo.[Transaction]` because TRANSACTION is a reserved word in T-SQL.
- Flag unsupported functions, implicit casts, destructive DDL, dynamic SQL, and timezone-sensitive logic in code comments.
- Always generate or update reconciliation tests in `tests/` for migrated objects.
- Fabric Warehouse does not enforce primary keys; rely on `tests/key_uniqueness_check.sql` to assert uniqueness.

## Pipeline Rules
- Separate initial and delta loads.
- Use a watermark column (typically `UPDATED_AT`) for delta loads on transaction-like tables.
- Partition large initial loads (`pipelines/initial_load_transaction_partitioned.json` pattern).
- Reference credentials only via Key Vault or managed identity. Never inline secrets.

## Fabric Notebook Rules
- Notebooks under `fabric/*.Notebook/` are stored in Git integration format. Edit `notebook-content.py` directly using the `# CELL ********************` and `# MARKDOWN ********************` separators; do not rewrite the file structure.
- Markdown cell content must be prefixed with `# ` (each line) so the file stays a valid Python source.
- Each cell ends with a `# METADATA ********************` block declaring the cell language (`python`, `markdown`, `synapsesql`). Keep the trailing METADATA block on every cell.
- Notebooks must NOT hard-code workspace / lakehouse GUIDs. The presenter binds the lakehouse via the *Add lakehouse* panel after the Notebook is created.
- Spark -> Warehouse writes use `df.write.mode("append").synapsesql("DWH_Modernization_Demo.dbo.<Table>")`. Always cast columns explicitly before write; CSV-inferred types will not match Warehouse types.

## Spark-free Demo Path
- `fabric/seed_data.sql`: Idempotent T-SQL `INSERT VALUES` covering all 4 tables (Customer 25, Branch 8, Account 40, Transaction 80 = 153 rows). Generated mechanically from `inventory/sample_data/*.csv`. Re-run is safe (each table is `DELETE`'d first).
- `fabric/validate.sql`: T-SQL replica of the `02_validate` Notebook's 4 checks (row count, key uniqueness, NULL rate, aggregate reconciliation against `vw_BranchBalance`). Returns 5 result grids with explicit PASS markers.
- Both files are designed to run in the Warehouse SQL editor (TDS endpoint, port 1433) and do NOT need Spark, Lakehouse, or Notebooks. This is the default demo path; the Notebook path is the supplementary one. When Fabric Trial Spark capacity returns HTTP 430 `TooManyRequestsForCapacity`, switch to these SQL files.
- When regenerating `seed_data.sql` (e.g., after updating sample CSVs), keep the existing `INSERT VALUES` style and the leading `DELETE FROM` for idempotency. Do not introduce `MERGE` or `COPY INTO` (would re-introduce Spark / external dependencies).

## API Rules
- Define the OpenAPI contract first, then implement against curated Fabric outputs.
- Do not expose raw operational tables.
- Document authorization assumptions and rate limits in comments.

## Security Rules
- Never output secrets, connection strings, or real customer data.
- Use managed identity or Key Vault references for credentials.
- Treat production deployment as a human-approved step.
- Synthetic data only. Block PII-style fields (real names, real account numbers, マイナンバー, etc.).

## Review Etiquette
- Treat Copilot output as a first draft. Always require human review before merge.
- When reviewing, surface: dialect drift, type/precision loss, missing reconciliation tests, secret patterns, performance risks on high-volume tables (`TRANSACTION`).
- Cite the file and line in review comments. Suggest concrete fixes, not vague concerns.
