# Copilot Code Review コメント例

`feature/migrate-customer-domain` PR に対して Copilot Code Review が出した（想定の）コメントを、デモ用に整理したサンプル集。実画面の代わりにこの Markdown を投影し、観客に「Copilot レビューはこういうトーンと粒度で動く」を伝える。

各コメントは以下の構造で示す:
- **対象**: `path:line` 形式の指摘箇所
- **重要度**: `must-fix` / `should-fix` / `nit`
- **指摘**: 機械的に発見できる事実
- **示唆**: 修正の方向性（Copilot は実装の代替を提示するが、最終決定は人間）

## 1. `fabric/warehouse_project/Tables/dbo.Customer.sql:5`

- **重要度**: should-fix
- **指摘**: `RiskScore DECIMAL(5,2) NULL` は Netezza 側の `NUMERIC(5,2)` と精度が一致していますが、許容 NULL が業務要件と整合しているかが確認できません。`source_dwh/ddl/nz_customer.sql` には `NOT NULL` 制約はありませんが、`docs/sql_dialect_mapping.md` の「NULL とゼロ件処理」節に従い、ロード時の `NULL` 率を計測する必要があります。
- **示唆**: `tests/null_rate_check.sql` を更新済みであれば本指摘は解消。未更新の場合は PR に追加してください。

## 2. `fabric/warehouse_project/Tables/dbo.Branch.sql:1-12`

- **重要度**: should-fix
- **指摘**: `BranchName VARCHAR(60)` は SBCS を想定した宣言です。日本語の全角文字列が業務上含まれる場合、`NVARCHAR(60)` のほうが安全です。`-- TODO(reviewer):` コメントを残しているのは把握していますが、PR 説明にも明示することを推奨します。
- **示唆**: 業務側で結論が出るまで本 PR では `VARCHAR(60)` を維持、PoC Week 3 で意思決定する旨を `Out of Scope` に追記してください。

## 3. `fabric/warehouse_project/Views/dbo.vw_BranchBalance.sql:5`

- **重要度**: should-fix
- **指摘**: `COUNT(*)` は `INT` の範囲を超え得る取引集計です。`COUNT_BIG(*)` に揃えることで、大量行数のリスクを避けられます。本 PR ですでに `COUNT_BIG(*)` を採用しているため確認のみ。
- **示唆**: 修正不要。`docs/sql_dialect_mapping.md` の「レビューで必ず確認する項目 (4)」を満たしています。

## 4. `tests/key_uniqueness_check.sql:1`

- **重要度**: must-fix
- **指摘**: 既存テストは `dbo.Customer` のみを対象としています。本 PR では `dbo.Branch` も新規追加されているため、`BranchId` の一意性確認 SQL が不足しています。
- **示唆**: 同ファイルに `UNION ALL` で `dbo.Branch` の重複検出を追加するか、`tests/key_uniqueness_check_branch.sql` を新規作成してください。

## 5. `.github/workflows/security-scan.yml`（PR には含まれていない）

- **重要度**: nit
- **指摘**: `secret-scan` ジョブが「pattern detected」で fail した場合、ヒット箇所がログに出るためデモ画面で本文が露出するリスクがあります。実環境では `--no-line-number` か、出力に `:::add-mask::` を併用してください。
- **示唆**: 本 PR のスコープ外。`feature/ci-hardening` ブランチ等で別 PR を切ってください。

## 6. `pipelines/initial_load_customer.json`（PR には含まれていない）

- **重要度**: should-fix
- **指摘**: 本 PR 内で `dbo.Customer` を作成しましたが、対応する初期ロードパイプラインは既存定義のままです。`auth` フィールドが定義されていないため、`.github/instructions/pipeline.instructions.md` の規約に違反する余地があります。
- **示唆**: 順序依存の PR で `auth.mode: managed_identity` と `key_vault_reference` を追加する旨を、本 PR の `Risks and Rollback` 節へ追記してください。

## 7. `inventory/dwh_objects.csv:5`

- **重要度**: nit
- **指摘**: `BRANCH` 行を追加しましたが、`estimated_rows` を `1500` と仮置きしています。出典は明示できますか?
- **示唆**: `inventory/migration_complexity.md` で `Branch` の根拠を追記しておくと、量産移行時の見積もりが揃います。

---

## レビュア向け使い方

1. デモ中は、まず「Copilot レビューは一次レビューであり、最終判断は人間」を口頭で宣言する。
2. 上記コメントの **must-fix** 1 件を中心に取り上げ、`tests/key_uniqueness_check.sql` を例に「修正 → コミット追加 → CI 再実行」のフローをイメージさせる。
3. **should-fix** と **nit** はあえて議論しないことで、「人間が優先度を決める」という統制を強調する。
