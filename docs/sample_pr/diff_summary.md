# Diff Summary: feature/migrate-customer-domain → main

`feature/migrate-customer-domain` ブランチが `main` に対して持つ変更の要約。デモのシーン 3 で「Files Changed タブ」の代わりに投影する。実 PR では GitHub の Files タブをそのまま見せること。

## 変更ファイル一覧

| 区分 | ファイル | 変更 | 行数（目安） |
|---|---|---|---:|
| 追加 | `source_dwh/ddl/nz_branch.sql` | 既存 DWH の BRANCH マスタ DDL を新規取り込み | +12 |
| 変更 | `fabric/warehouse_project/Tables/dbo.Customer.sql` | Netezza DDL から変換した Fabric Warehouse 用 T-SQL（コメントで変換前提を明示） | +9 / -1 |
| 追加 | `fabric/warehouse_project/Tables/dbo.Branch.sql` | BRANCH の Fabric 向け T-SQL を新規追加 | +13 |
| 追加 | `tests/null_rate_check.sql` | 4 列の NULL 率を測定する SQL を新規追加 | +27 |
| 変更 | `tests/sample_test_results.md` | NULL 率行を追加し、しきい値を明示 | +7 / -3 |
| 変更 | `inventory/dwh_objects.csv` | BRANCH と DAILY_BALANCE の 2 行を追加 | +2 / -0 |
| 変更 | `inventory/dependency_map.md` | BRANCH と DAILY_BALANCE を含めた依存表に更新 | +3 / -1 |

## 主な変更ポイント（口頭で説明する順）

1. **`source_dwh/ddl/nz_branch.sql`** — 既存 DWH の生資材として、`DISTRIBUTE ON` を含む元の DDL を Git へ取り込んだ。これは「移行前」の正のスナップショット。
2. **`fabric/warehouse_project/Tables/dbo.Customer.sql`** — Copilot カード #1 で変換した結果を人間が手直し。`-- Mapping notes:` ブロックで変換前提を明示。`DISTRIBUTE ON` が消え、`TIMESTAMP` が `DATETIME2(6)` に、`PRIMARY KEY` 句が省かれていることを指差し説明する。
3. **`fabric/warehouse_project/Tables/dbo.Branch.sql`** — 同じパターンで Branch を追加。`-- TODO(reviewer): VARCHAR vs NVARCHAR` を残してあり、PR 本文の `SQL Dialect Notes` と整合している。
4. **`tests/null_rate_check.sql`** — Copilot カード #3 で生成したテストを採用。`UNION ALL` で 4 列を並べた構造をそのまま見せ、「テストも Git で管理される」を伝える。
5. **`tests/sample_test_results.md`** — 閾値（CustomerSegment ≤ 5%、RiskScore ≤ 2%）と観測値を明記。CI の job summary に転載され、PR Conversation に貼られる流れを説明する。
6. **`inventory/dwh_objects.csv` / `dependency_map.md`** — 棚卸し表と依存マップを更新。本 PR の対象テーブルだけでなく、後続 PR の前提（`DAILY_BALANCE`）まで先に登録した。

## あえて含めなかった変更

- `pipelines/initial_load_customer.json` のパラメータ追加 → 順序依存の後続 PR で対応
- Power BI の再公開 → スコープ外
- Entra ID 認証 → デモ目的の枠外。本番準備は PoC Week 4-5 を想定

## 差分の見せ方（操作手順）

1. ブランチ移動: `git switch feature/migrate-customer-domain`
2. 差分: `git diff --stat main..feature/migrate-customer-domain`
3. ファイル別: `git diff main..feature/migrate-customer-domain -- fabric/warehouse_project/Tables/dbo.Customer.sql`
4. CI 結果: PR の Checks タブを開き、3 ジョブがすべて緑であることを確認

Web GitHub の Files Changed タブで上記順に画面遷移すれば、3〜4 分で説明が完結する。
