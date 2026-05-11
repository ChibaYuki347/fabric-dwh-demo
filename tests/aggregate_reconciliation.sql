-- Compare aggregate amount for transaction migration batch.
SELECT 'TRANSACTION_AMOUNT' AS CheckName, SourceAmount, TargetAmount, SourceAmount - TargetAmount AS Difference
FROM (
    SELECT CAST(1234567890.12 AS DECIMAL(18,2)) AS SourceAmount,
           CAST(1234567890.12 AS DECIMAL(18,2)) AS TargetAmount
) AS r;
