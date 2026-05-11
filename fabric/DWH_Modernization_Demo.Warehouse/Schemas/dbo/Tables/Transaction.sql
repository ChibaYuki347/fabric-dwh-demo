-- Fabric Warehouse target ported from source_dwh/ddl/nz_transaction.sql
-- Mapping notes:
--   * Table name "Transaction" is a T-SQL reserved word; always reference as dbo.[Transaction].
--   * NUMERIC(18,2) -> DECIMAL(18,2).
--   * TIMESTAMP -> DATETIME2(6).
--   * No PRIMARY KEY emitted (Fabric Warehouse does not enforce PKs).
CREATE TABLE dbo.[Transaction] (
    TransactionId BIGINT NOT NULL,
    AccountId BIGINT NOT NULL,
    TransactionDate DATE NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    ChannelCode VARCHAR(10) NULL,
    UpdatedAt DATETIME2(6) NULL
);
