-- Fabric Warehouse target ported from source_dwh/ddl/nz_account.sql
-- Mapping notes:
--   * Netezza DISTRIBUTE ON clause removed; Fabric Warehouse distributes automatically.
--   * BIGINT, INT, VARCHAR, CHAR, DATE all map 1:1.
--   * TIMESTAMP -> DATETIME2(6) preserves sub-second precision used by source ETL.
--   * No PRIMARY KEY emitted; Fabric Warehouse does not enforce PKs (uniqueness is asserted by tests/).
CREATE TABLE dbo.Account (
    AccountId BIGINT NOT NULL,
    CustomerId INT NOT NULL,
    BranchId INT NOT NULL,
    AccountType VARCHAR(20) NULL,
    StatusCode CHAR(1) NULL,
    OpenDate DATE NULL,
    UpdatedAt DATETIME2(6) NULL
);
