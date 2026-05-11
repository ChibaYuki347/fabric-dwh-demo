# Sample PR Description: feat(customer): migrate CORE.CUSTOMER and CORE.BRANCH to Fabric Warehouse

> 本ファイルは `.github/pull_request_template.md` をそのまま埋めた完成例である。デモのシーン 3 で「PR Conversation 冒頭」として投影する。

## Purpose

既存 DWH の `CORE.CUSTOMER` および `CORE.BRANCH` を Microsoft Fabric Warehouse `wh_dwh_demo` の `dbo.Customer` / `dbo.Branch` へ移送するための、初回 PR です。あわせて再照合テスト 4 種を追加し、PR テンプレート/`.github/instructions/sql-migration.instructions.md` の遵守を確認しました。データ取り込みパイプラインは別 PR で対応します。

## Migration Scope

- Source objects: `CORE.CUSTOMER`、`CORE.BRANCH`（`source_dwh/ddl/nz_customer.sql`、`source_dwh/ddl/nz_branch.sql`）
- Fabric target objects: `dbo.Customer`、`dbo.Branch`（`fabric/warehouse_project/Tables/dbo.Customer.sql`、`dbo.Branch.sql`）
- Data volume / refresh pattern: Customer 約 100 万行 / 日次、Branch 約 1,500 行 / 月次（`inventory/dwh_objects.csv` 準拠）
- Affected pipelines: 本 PR では新規追加なし（既存 `pipelines/initial_load_customer.json` の更新は別 PR で実施）
- Affected APIs / Power BI semantic models: 直接の変更なし。`api/openapi.yaml` の curated view 経由のみ

## Copilot-Assisted Work

`docs/copilot_prompt_cards.md` のカード #1（DDL 変換）・#2（ビュー review）・#3（再照合テスト生成）を使用しました。

- Prompts used: カード #1, #3
- Files Copilot drafted: `fabric/warehouse_project/Tables/dbo.Customer.sql`、`fabric/warehouse_project/Tables/dbo.Branch.sql`、`tests/null_rate_check.sql`
- Files Copilot reviewed: `fabric/warehouse_project/Views/dbo.vw_BranchBalance.sql`（既存）
- Human validation performed:
  - 型マッピング（`TIMESTAMP` → `DATETIME2(6)`、`NUMERIC(5,2)` → `DECIMAL(5,2)`）を `docs/sql_dialect_mapping.md` と突き合わせて確認
  - `DISTRIBUTE ON` の削除と、`PRIMARY KEY` 句を出力しない方針の徹底
  - `tests/null_rate_check.sql` の閾値（CustomerSegment ≤ 5%、RiskScore ≤ 2%）を業務側仮置きで合意

## Validation Evidence

- [x] SQL build check passed (`.github/workflows/sql-build.yml`)
- [x] Row count reconciliation completed (`tests/row_count_reconciliation.sql`、Customer のみ実施)
- [x] Aggregate reconciliation completed (`tests/aggregate_reconciliation.sql`、Customer の RiskScore SUM で検証)
- [x] Key uniqueness check completed (`tests/key_uniqueness_check.sql`、CustomerId / BranchId)
- [x] NULL rate check completed (`tests/null_rate_check.sql`、4 列対象)
- [x] Security scan passed (`.github/workflows/security-scan.yml`)
- [x] Sample test results updated (`tests/sample_test_results.md`、NULL 率 4 行追加)

## SQL Dialect Notes

- `CORE.CUSTOMER.RISK_SCORE NUMERIC(5,2)` → `dbo.Customer.RiskScore DECIMAL(5,2)`: `docs/sql_dialect_mapping.md` のデフォルト規則に従う。乖離なし。
- `CORE.BRANCH.BRANCH_NAME VARCHAR(60)`: 全角文字列を想定するが Netezza は SBCS。Fabric では `NVARCHAR(60)` へ昇格すべきか、PoC Week 3 で業務側と再確認するため `-- TODO(reviewer):` を `dbo.Branch.sql` に残しています。
- `DISTRIBUTE ON (CUSTOMER_ID)` および `DISTRIBUTE ON (BRANCH_ID)` は除去（Fabric Warehouse は明示クラスタリング不要）。

## Risks and Rollback

- 移行リスク: Customer 100 万行の初期ロードは別 PR で実施するが、watermark 列 `UPDATED_AT` が一部 NULL のレコードを Netezza 側で確認したため、`tests/null_rate_check.sql` の閾値次第で初期ロード後の再照合が赤色になり得る。
- ロールバック手順: 本 PR の SQL は `CREATE TABLE` のみで破壊的でないため、問題発生時は `git revert` で当該コミットを差し戻し、Fabric Dev で `DROP TABLE dbo.Customer; DROP TABLE dbo.Branch;` を手動実行する。
- Blast radius: Dev のみ。Test/Prod は別途承認ステップで昇格。

## Out of Scope

- `CORE.ACCOUNT`、`CORE.TRANSACTION` の移行（後続 PR で対応）
- `pipelines/initial_load_customer.json` のパラメータ追加（後続 PR）
- Power BI セマンティックモデルの再公開
- 認証統制（Entra ID / Key Vault）の本番設定切り替え

---

### レビュアー向けメモ

- Copilot は `dbo.Customer.sql` の `RiskScore` 列に `NULL` を許容しているが、Netezza 側は NULL 不可制約がなく、業務的にも欠損があり得るため意図的に NULL 許容。
- `dbo.Branch.sql` には `-- TODO(reviewer): VARCHAR vs NVARCHAR` コメントが残っている。Week 3 にて結論を出すまで保留してください。
- 本 PR をマージ後、`pipelines/` 系の PR を開きます。順序依存です。
