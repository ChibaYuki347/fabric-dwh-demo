# Migration Complexity

| Area | Complexity | Reason | Demo Treatment |
|---|---|---|---|
| Customer master | Medium | Data type mapping and key validation | Show DDL conversion |
| Transaction fact | High | Volume, partitioning, delta load | Show pipeline and tests |
| Branch balance view | Medium | Aggregation and date logic | Show SQL review |
| Daily balance ETL | High | Batch dependency and reconciliation | Show pipeline runbook |
