-- Fabric Warehouse target draft generated from source_dwh/ddl/nz_account.sql
CREATE TABLE dbo.Account (
    AccountId BIGINT NOT NULL,
    CustomerId INT NOT NULL,
    BranchId INT NOT NULL,
    AccountType VARCHAR(20) NULL,
    StatusCode CHAR(1) NULL,
    OpenDate DATE NULL,
    UpdatedAt DATETIME2(6) NULL
);
