---
applyTo:
  - "source_dwh/**/*.sql"
  - "fabric/*.Warehouse/**/*.sql"
  - "fabric/post-deployment/**/*.sql"
  - "tests/**/*.sql"
---

# SQL Migration Instructions

When converting source DWH SQL to Fabric Warehouse-compatible T-SQL:

1. Preserve business logic. If you are not sure how a clause maps, leave a `-- TODO(reviewer):` comment and stop — do not silently change semantics.
2. Explain non-trivial data type mappings in a SQL comment at the top of the file, citing `docs/sql_dialect_mapping.md`.
3. Drop Netezza-only clauses (`DISTRIBUTE ON`, `ORGANIZE ON`, `CALL`-based stored procedures, `NZ_*` system functions, and `NULL` ordering hints) and note the removal.
4. Map `TIMESTAMP` to `DATETIME2(6)` by default; map `NUMERIC(p,s)` to `DECIMAL(p,s)` keeping precision and scale.
5. Quote `Transaction` as `dbo.[Transaction]` because TRANSACTION is reserved in T-SQL.
6. Do not emit `CREATE INDEX` on Fabric Warehouse; let the engine manage statistics. If an index is critical, raise it as a discussion point in the PR body.
7. Add or update at least one reconciliation test in `tests/` for every migrated object: row count, aggregate value, key uniqueness, and NULL rate when the column is nullable in source but constrained in target.
8. Flag implicit casts, dynamic SQL, and timezone-sensitive logic explicitly. Never assume server-local time.
9. Never use `SELECT *` in Fabric Warehouse views that feed Power BI or APIs; enumerate columns.
