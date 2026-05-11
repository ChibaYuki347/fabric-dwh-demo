-- Detect duplicate keys in migrated target objects.
SELECT CustomerId, COUNT(*) AS DuplicateCount
FROM dbo.Customer
GROUP BY CustomerId
HAVING COUNT(*) > 1;
