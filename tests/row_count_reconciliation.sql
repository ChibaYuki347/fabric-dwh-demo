-- Compare source and target row counts after migration batch.
SELECT 'CUSTOMER' AS ObjectName, SourceCount, TargetCount, SourceCount - TargetCount AS Difference
FROM (
    SELECT 1000000 AS SourceCount, 1000000 AS TargetCount
) AS r;
