-- Fabric Warehouse target draft generated from source_dwh/ddl/nz_transaction.sql
CREATE TABLE dbo.[Transaction] (
    TransactionId BIGINT NOT NULL,
    AccountId BIGINT NOT NULL,
    TransactionDate DATE NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    ChannelCode VARCHAR(10) NULL,
    UpdatedAt DATETIME2(6) NULL
);
