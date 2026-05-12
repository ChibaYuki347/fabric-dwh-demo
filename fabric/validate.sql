-- =============================================================================
-- Fabric Warehouse data quality validation (Spark-free path)
-- =============================================================================
-- Purpose : Run the same 4 categories of data quality checks that the
--           02_validate Notebook performs, but as pure T-SQL so they can
--           be executed in the Warehouse SQL editor without Spark.
--
-- Usage   : Open Warehouse > New SQL query > paste this file > Run.
--           Each section returns its own result grid. Expected output is
--           documented inline. Demo can be driven by showing one section
--           at a time.
--
-- Sections:
--   1. Row count reconciliation     (4 tables vs expected)
--   2. Key uniqueness check          (no duplicate PKs)
--   3. NULL rate on critical columns (<= threshold)
--   4. Aggregate reconciliation      (vw_BranchBalance vs raw)
--
-- Expected end state: every row in section 1 = PASS,
--                     sections 2/4 return 0 rows,
--                     section 3 returns 0.0000 NullRate for all columns.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Row count reconciliation
-- -----------------------------------------------------------------------------
-- Compare actual row count vs the expected count baked into the seed file.
-- Result must show all 4 rows with Result = 'PASS'.
SELECT
    'Customer'    AS TableName,
    25            AS ExpectedRows,
    (SELECT COUNT(*) FROM dbo.Customer)        AS ActualRows,
    CASE WHEN (SELECT COUNT(*) FROM dbo.Customer)        = 25 THEN 'PASS' ELSE 'FAIL' END AS Result
UNION ALL SELECT
    'Branch',     8,
    (SELECT COUNT(*) FROM dbo.Branch),
    CASE WHEN (SELECT COUNT(*) FROM dbo.Branch)          = 8  THEN 'PASS' ELSE 'FAIL' END
UNION ALL SELECT
    'Account',    40,
    (SELECT COUNT(*) FROM dbo.Account),
    CASE WHEN (SELECT COUNT(*) FROM dbo.Account)         = 40 THEN 'PASS' ELSE 'FAIL' END
UNION ALL SELECT
    'Transaction', 80,
    (SELECT COUNT(*) FROM dbo.[Transaction]),
    CASE WHEN (SELECT COUNT(*) FROM dbo.[Transaction])   = 80 THEN 'PASS' ELSE 'FAIL' END;


-- -----------------------------------------------------------------------------
-- 2. Key uniqueness check
-- -----------------------------------------------------------------------------
-- Returns any primary key that appears more than once across all 4 tables.
-- Expected: 0 rows.
SELECT 'Customer.CustomerId' AS KeyName, CAST(CustomerId AS VARCHAR(50)) AS KeyValue, COUNT(*) AS DuplicateCount
FROM dbo.Customer GROUP BY CustomerId HAVING COUNT(*) > 1
UNION ALL
SELECT 'Branch.BranchId', CAST(BranchId AS VARCHAR(50)), COUNT(*)
FROM dbo.Branch GROUP BY BranchId HAVING COUNT(*) > 1
UNION ALL
SELECT 'Account.AccountId', CAST(AccountId AS VARCHAR(50)), COUNT(*)
FROM dbo.Account GROUP BY AccountId HAVING COUNT(*) > 1
UNION ALL
SELECT 'Transaction.TransactionId', CAST(TransactionId AS VARCHAR(50)), COUNT(*)
FROM dbo.[Transaction] GROUP BY TransactionId HAVING COUNT(*) > 1;


-- -----------------------------------------------------------------------------
-- 3. NULL rate on critical columns
-- -----------------------------------------------------------------------------
-- Sample data is complete so all NullRate values must be 0.0000.
-- Threshold guidance: tests/sample_test_results.md (<= 0.0500 acceptable
-- in production; demo expects exactly 0).
SELECT 'Customer.CustomerSegment' AS ColumnName,
       COUNT(*) AS TotalRows,
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
SELECT 'Transaction.ChannelCode',
       COUNT(*),
       SUM(CASE WHEN ChannelCode IS NULL THEN 1 ELSE 0 END),
       CAST(SUM(CASE WHEN ChannelCode IS NULL THEN 1 ELSE 0 END) * 1.0
            / NULLIF(COUNT(*), 0) AS DECIMAL(5,4))
FROM dbo.[Transaction];


-- -----------------------------------------------------------------------------
-- 4. Aggregate reconciliation (vw_BranchBalance integrity)
-- -----------------------------------------------------------------------------
-- The view aggregates Transaction.Amount by (BranchId, TransactionDate).
-- Direct re-aggregation of the base tables must produce the same totals.
-- Expected: 0 rows (any row here means the view drifted from base tables).
WITH view_agg AS (
    SELECT BranchId, TransactionDate, DailyAmount, TransactionCount
    FROM dbo.vw_BranchBalance
),
base_agg AS (
    SELECT a.BranchId,
           t.TransactionDate,
           SUM(t.Amount)    AS DailyAmount,
           COUNT_BIG(*)     AS TransactionCount
    FROM dbo.Account AS a
    JOIN dbo.[Transaction] AS t ON a.AccountId = t.AccountId
    GROUP BY a.BranchId, t.TransactionDate
)
SELECT v.BranchId,
       v.TransactionDate,
       v.DailyAmount       AS ViewAmount,
       b.DailyAmount       AS BaseAmount,
       v.TransactionCount  AS ViewCount,
       b.TransactionCount  AS BaseCount
FROM view_agg v
JOIN base_agg b ON v.BranchId = b.BranchId AND v.TransactionDate = b.TransactionDate
WHERE v.DailyAmount      <> b.DailyAmount
   OR v.TransactionCount <> b.TransactionCount;


-- -----------------------------------------------------------------------------
-- Optional: presenter snapshot (top 5 days by branch for the demo screen)
-- -----------------------------------------------------------------------------
SELECT TOP 10
    b.BranchName,
    v.TransactionDate,
    v.DailyAmount,
    v.TransactionCount
FROM dbo.vw_BranchBalance v
JOIN dbo.Branch b ON v.BranchId = b.BranchId
ORDER BY v.TransactionDate DESC, v.DailyAmount DESC;
