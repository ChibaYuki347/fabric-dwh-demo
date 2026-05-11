# Sample Test Results

These figures are illustrative for the demo. CI publishes this file as the
"data quality check" artifact when no real warehouse is connected.

| Check | Threshold | Result | Evidence |
|---|---|---|---|
| Customer row count reconciliation | abs diff = 0 | Passed | Source 1,000,000 / Target 1,000,000 |
| Transaction amount reconciliation | abs diff < 0.01 | Passed | Difference 0.00 |
| Customer key uniqueness | 0 duplicates | Passed | 0 duplicate keys |
| Customer.CustomerSegment NULL rate | <= 0.05 | Passed | Observed 0.0120 |
| Customer.RiskScore NULL rate | <= 0.02 | Passed | Observed 0.0000 |
| Account.AccountType NULL rate | <= 0.01 | Passed | Observed 0.0000 |
| Transaction.ChannelCode NULL rate | <= 0.05 | Passed | Observed 0.0080 |
| Dangerous DDL scan | none | Passed | No destructive DDL detected |
| Secret scan | none | Passed | No tokens or connection strings detected |
