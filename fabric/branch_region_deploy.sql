-- =====================================================================
-- fabric/branch_region_deploy.sql  —  Branch_Region ディメンション追加
-- =====================================================================
-- 用途:
--   ルックアップテーブル dbo.Branch_Region を Fabric Warehouse に追加し、
--   Branch.RegionCode → 地域名・国コードのマッピングを提供する。
--   dbo.Branch と RegionCode で JOIN 可能。
--
-- 実行方法:
--   Fabric SQL editor で全選択 → Run。冪等 (何度実行しても安全)。
--
-- Netezza → T-SQL 変換メモ:
--   * DISTRIBUTE ON (REGION_CD) → 削除 (Fabric Warehouse は分散指定なし)
--   * PRIMARY KEY (REGION_CD) → 削除; 一意性は tests/key_uniqueness_check.sql で検証
--   * TIMESTAMP → DATETIME2(6)
--   * CHAR(3) → VARCHAR(3)  (Fabric Warehouse は固定長より可変長を推奨)
--   * カラム名を PascalCase に統一: REGION_CD → RegionCode 等
--   参照: docs/sql_dialect_mapping.md
-- =====================================================================

-- ---- DROP (冪等) ----------------------------------------------------
DROP TABLE IF EXISTS dbo.Branch_Region;

-- ---- CREATE TABLE ---------------------------------------------------
-- Removed: DISTRIBUTE ON (REGION_CD)  -- Netezza-only clause; not supported on Fabric Warehouse
-- Removed: PRIMARY KEY (REGION_CD)    -- Fabric Warehouse does not enforce PK constraints
CREATE TABLE dbo.Branch_Region (
    RegionCode  VARCHAR(10)   NOT NULL,
    RegionName  VARCHAR(40)   NOT NULL,
    CountryCode VARCHAR(3)    NOT NULL,
    UpdatedAt   DATETIME2(6)  NULL
);

-- ---- SEED DATA (6 region codes) ------------------------------------
INSERT INTO dbo.Branch_Region (RegionCode, RegionName, CountryCode, UpdatedAt) VALUES
    ('EAST',    '関東',   'JPN', '2026-05-01T00:00:00'),
    ('CENTRAL', '中部',   'JPN', '2026-05-01T00:00:00'),
    ('WEST',    '関西',   'JPN', '2026-05-01T00:00:00'),
    ('NORTH',   '北海道', 'JPN', '2026-05-01T00:00:00'),
    ('SOUTH',   '沖縄',   'JPN', '2026-05-01T00:00:00'),
    ('VIRTUAL', 'オンライン', 'JPN', '2026-05-01T00:00:00');
