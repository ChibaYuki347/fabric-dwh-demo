# Dependency Map

| Source Object | Depends On | Fabric Target | Notes |
|---|---|---|---|
| CUSTOMER | None | dbo.Customer | Master table |
| BRANCH | None | dbo.Branch | Branch master, low refresh frequency |
| ACCOUNT | CUSTOMER, BRANCH | dbo.Account | Account master |
| TRANSACTION | ACCOUNT | dbo.[Transaction] | High-volume transaction fact, partitioned load |
| VW_BRANCH_BALANCE | ACCOUNT, TRANSACTION, BRANCH | dbo.vw_BranchBalance | Power BI and API source |
| DAILY_BALANCE | VW_BRANCH_BALANCE | dbo.DailyBalance | Materialized daily fact, populated by ETL |
| DAILY_BALANCE_JOB | TRANSACTION | pipelines/delta_load_watermark.json | Daily aggregation pipeline |
