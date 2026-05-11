-- Fabric Warehouse target draft generated from source_dwh/ddl/nz_customer.sql
CREATE TABLE dbo.Customer (
    CustomerId INT NOT NULL,
    CustomerSegment VARCHAR(20) NULL,
    OpenDate DATE NULL,
    RiskScore DECIMAL(5,2) NULL,
    UpdatedAt DATETIME2(6) NULL
);
