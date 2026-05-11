-- Fabric Warehouse target draft for the curated daily balance fact.
-- Produced by pipelines/delta_load_watermark.json after reconciliation passes.
-- Notes:
--   * Amount uses DECIMAL(18,2) to preserve source NUMERIC precision/scale.
--   * BusinessDate is the partitioning candidate when partition support is enabled.
--   * Primary key is BranchId + BusinessDate; uniqueness is enforced by ETL upsert,
--     not by a Warehouse constraint (Fabric Warehouse does not enforce PK).
CREATE TABLE dbo.DailyBalance (
    BranchId INT NOT NULL,
    BusinessDate DATE NOT NULL,
    DailyAmount DECIMAL(18,2) NOT NULL,
    TransactionCount BIGINT NOT NULL,
    LoadedAt DATETIME2(6) NOT NULL
);
