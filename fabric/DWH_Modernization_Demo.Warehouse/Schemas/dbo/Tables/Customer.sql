-- Fabric Warehouse target ported from source_dwh/ddl/nz_customer.sql
-- Mapping notes:
--   * NUMERIC(5,2) -> DECIMAL(5,2) (synonyms in T-SQL; DECIMAL preferred for portability).
--   * TIMESTAMP -> DATETIME2(6).
--   * No PRIMARY KEY clause emitted; uniqueness is asserted via tests/key_uniqueness_check.sql.
CREATE TABLE dbo.Customer (
    CustomerId INT NOT NULL,
    CustomerSegment VARCHAR(20) NULL,
    OpenDate DATE NULL,
    RiskScore DECIMAL(5,2) NULL,
    UpdatedAt DATETIME2(6) NULL
);
