# Copilot Instructions for Fabric DWH Migration Demo

## Project Context
This repository demonstrates migration from an existing IBM PureData / Netezza-style DWH to Microsoft Fabric. All generated code is draft and requires human review. Treat this repository as a migration factory template, not as a production deployment artifact.

## Repository Layout
- `source_dwh/`: Synthetic Netezza-style DDL, views, ETL metadata. Never edit to look like real customer schemas.
- `fabric/warehouse_project/`: Fabric Warehouse target SQL (T-SQL). Mirrors a SQL database project layout.
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
