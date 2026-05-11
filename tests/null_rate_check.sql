-- NULL rate check across critical columns. Run after each migration batch.
-- Threshold guidance lives in tests/sample_test_results.md; this query reports
-- raw rates so reviewers can compare against the documented thresholds.
SELECT 'Customer.CustomerSegment' AS ColumnName,
       COUNT(*) AS RowCount,
       SUM(CASE WHEN CustomerSegment IS NULL THEN 1 ELSE 0 END) AS NullCount,
       CAST(SUM(CASE WHEN CustomerSegment IS NULL THEN 1 ELSE 0 END) * 1.0
            / NULLIF(COUNT(*), 0) AS DECIMAL(5,4)) AS NullRate
FROM dbo.Customer
UNION ALL
SELECT 'Customer.RiskScore',
       COUNT(*),
       SUM(CASE WHEN RiskScore IS NULL THEN 1 ELSE 0 END),
       CAST(SUM(CASE WHEN RiskScore IS NULL THEN 1 ELSE 0 END) * 1.0
            / NULLIF(COUNT(*), 0) AS DECIMAL(5,4))
FROM dbo.Customer
UNION ALL
SELECT 'Account.AccountType',
       COUNT(*),
       SUM(CASE WHEN AccountType IS NULL THEN 1 ELSE 0 END),
       CAST(SUM(CASE WHEN AccountType IS NULL THEN 1 ELSE 0 END) * 1.0
            / NULLIF(COUNT(*), 0) AS DECIMAL(5,4))
FROM dbo.Account
UNION ALL
SELECT '[Transaction].ChannelCode',
       COUNT(*),
       SUM(CASE WHEN ChannelCode IS NULL THEN 1 ELSE 0 END),
       CAST(SUM(CASE WHEN ChannelCode IS NULL THEN 1 ELSE 0 END) * 1.0
            / NULLIF(COUNT(*), 0) AS DECIMAL(5,4))
FROM dbo.[Transaction];
