-- =====================================================================
-- fabric/ddl_deploy.sql  —  Fabric Warehouse 物理オブジェクト再構築
-- =====================================================================
-- 用途:
--   Warehouse `DWH_Modernization_Demo` のテーブル/ビューが消えた場合
--   (例: Fabric Workspace の "Update from Git" で .sqlproj 形式の空の
--    プロジェクトが取り込まれてテーブルが drop された場合) に、
--   このファイルを Fabric SQL editor で全選択 → Run することで
--   5 テーブル + 1 ビューを冪等に再構築する。
--
-- 実行順:
--   1) (この DDL) SQL editor で paste → Run     ←  本ファイル
--   2) fabric/seed_data.sql を paste → Run      ←  153 行の INSERT
--   3) fabric/validate.sql を paste → Run       ←  PASS 確認
--
-- 注意:
--   * `IF EXISTS` 付き DROP で冪等性を確保。view → tables の順で drop。
--   * Fabric Warehouse は PRIMARY KEY を強制しないため CREATE TABLE に
--     PK 句は含めない。一意性は tests/key_uniqueness_check.sql で検証。
--   * Transaction は T-SQL 予約語のため `dbo.[Transaction]` と書く。
--   * このファイルは fabric/post-deployment/security.sql とは別。
--     security ロールの作成は別途 security.sql を Run すること。
-- =====================================================================

-- ---- DROP (view → tables の依存逆順) ---------------------------------
DROP VIEW  IF EXISTS dbo.vw_BranchBalance;
DROP TABLE IF EXISTS dbo.[Transaction];
DROP TABLE IF EXISTS dbo.DailyBalance;
DROP TABLE IF EXISTS dbo.Account;
DROP TABLE IF EXISTS dbo.Branch;
DROP TABLE IF EXISTS dbo.Customer;

-- ---- CREATE TABLE (FK 依存順: Customer → Branch → Account → ...) ----
-- Mapping notes:
--   * NUMERIC(5,2) -> DECIMAL(5,2)
--   * TIMESTAMP    -> DATETIME2(6)
--   * No PRIMARY KEY emitted; uniqueness asserted in tests/.
CREATE TABLE dbo.Customer (
    CustomerId      INT          NOT NULL,
    CustomerSegment VARCHAR(20)  NULL,
    OpenDate        DATE         NULL,
    RiskScore       DECIMAL(5,2) NULL,
    UpdatedAt       DATETIME2(6) NULL
);

CREATE TABLE dbo.Branch (
    BranchId    INT          NOT NULL,
    BranchName  VARCHAR(60)  NOT NULL,
    RegionCode  VARCHAR(10)  NULL,
    OpenDate    DATE         NULL,
    StatusCode  CHAR(1)      NULL,
    UpdatedAt   DATETIME2(6) NULL
);

-- Netezza DISTRIBUTE ON clause removed; Fabric Warehouse distributes automatically.
CREATE TABLE dbo.Account (
    AccountId   BIGINT       NOT NULL,
    CustomerId  INT          NOT NULL,
    BranchId    INT          NOT NULL,
    AccountType VARCHAR(20)  NULL,
    StatusCode  CHAR(1)      NULL,
    OpenDate    DATE         NULL,
    UpdatedAt   DATETIME2(6) NULL
);

-- Curated daily balance fact. ETL upsert enforces (BranchId, BusinessDate) uniqueness.
CREATE TABLE dbo.DailyBalance (
    BranchId         INT            NOT NULL,
    BusinessDate     DATE           NOT NULL,
    DailyAmount      DECIMAL(18,2)  NOT NULL,
    TransactionCount BIGINT         NOT NULL,
    LoadedAt         DATETIME2(6)   NOT NULL
);

-- "Transaction" is a T-SQL reserved word; always reference as dbo.[Transaction].
CREATE TABLE dbo.[Transaction] (
    TransactionId   BIGINT         NOT NULL,
    AccountId       BIGINT         NOT NULL,
    TransactionDate DATE           NOT NULL,
    Amount          DECIMAL(18,2)  NOT NULL,
    ChannelCode     VARCHAR(10)    NULL,
    UpdatedAt       DATETIME2(6)   NULL
);

-- ---- CREATE VIEW -----------------------------------------------------
-- Source: dbo.Account JOIN dbo.[Transaction] aggregated to (BranchId, TransactionDate).
-- Granted to the reader role in fabric/post-deployment/security.sql (not the base tables).
CREATE VIEW dbo.vw_BranchBalance AS
SELECT
    a.BranchId,
    t.TransactionDate,
    SUM(t.Amount)  AS DailyAmount,
    COUNT_BIG(*)   AS TransactionCount
FROM dbo.Account AS a
JOIN dbo.[Transaction] AS t
    ON a.AccountId = t.AccountId
GROUP BY a.BranchId, t.TransactionDate;
