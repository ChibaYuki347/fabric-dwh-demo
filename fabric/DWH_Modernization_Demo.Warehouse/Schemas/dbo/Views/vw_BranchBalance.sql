-- Curated view exposed to BI / API readers.
-- Source: dbo.Account JOIN dbo.[Transaction] aggregated to (BranchId, TransactionDate).
-- This view (not the base tables) is granted to the reader role in
-- fabric/post-deployment/security.sql.
CREATE VIEW dbo.vw_BranchBalance AS
SELECT
    a.BranchId,
    t.TransactionDate,
    SUM(t.Amount) AS DailyAmount,
    COUNT_BIG(*) AS TransactionCount
FROM dbo.Account AS a
JOIN dbo.[Transaction] AS t
    ON a.AccountId = t.AccountId
GROUP BY a.BranchId, t.TransactionDate;
