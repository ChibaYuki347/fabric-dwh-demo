-- Post-deployment security script for the Fabric Warehouse target.
--
-- IMPORTANT
-- ---------
-- Fabric Git integration does NOT include security objects (roles/GRANT) in the
-- Warehouse item. After the Warehouse is created via "Update from Git", run this
-- script manually against DWH_Modernization_Demo using either:
--   * the Fabric portal SQL editor, or
--   * scripts/reset_demo.sh which connects via ODBC and applies it.
--
-- Principles:
--   * Use Microsoft Entra ID groups, never SQL logins with passwords.
--   * Grant the minimum required object-level privileges.
--   * Curated marts (vw_BranchBalance, DailyBalance) are the only objects exposed to readers.
--   * The ETL service principal owns write paths; analysts only read.

-- Reader role: business users and downstream API service principals.
CREATE ROLE rl_dwh_reader;
GRANT SELECT ON OBJECT::dbo.vw_BranchBalance TO rl_dwh_reader;
GRANT SELECT ON OBJECT::dbo.DailyBalance     TO rl_dwh_reader;

-- ETL role: Data Factory pipeline managed identity.
CREATE ROLE rl_dwh_etl;
GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::dbo.Customer        TO rl_dwh_etl;
GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::dbo.Account         TO rl_dwh_etl;
GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::dbo.[Transaction]   TO rl_dwh_etl;
GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::dbo.Branch          TO rl_dwh_etl;
GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::dbo.DailyBalance    TO rl_dwh_etl;

-- Membership is bound to Entra ID groups by a human approver as a separate step:
--   ALTER ROLE rl_dwh_reader ADD MEMBER [grp-fabric-dwh-readers];
--   ALTER ROLE rl_dwh_etl    ADD MEMBER [mi-pl-dwh-migration-demo];
-- The ALTER ROLE statements are intentionally not executed here so that the
-- post-deployment script stays idempotent across environments (dev/test/prod).
