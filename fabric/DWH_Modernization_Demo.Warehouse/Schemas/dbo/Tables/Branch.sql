-- Fabric Warehouse target ported from source_dwh/ddl/nz_branch.sql
-- Mapping notes:
--   * VARCHAR widths preserved.
--   * TIMESTAMP -> DATETIME2(6) keeps sub-second precision used by source ETL.
--   * No DISTRIBUTE clause is emitted: Fabric Warehouse distributes automatically.
CREATE TABLE dbo.Branch (
    BranchId INT NOT NULL,
    BranchName VARCHAR(60) NOT NULL,
    RegionCode VARCHAR(10) NULL,
    OpenDate DATE NULL,
    StatusCode CHAR(1) NULL,
    UpdatedAt DATETIME2(6) NULL
);
