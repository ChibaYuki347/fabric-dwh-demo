# 移行 Runbook

本 Runbook は、1 つの DWH オブジェクト（例: `CORE.CUSTOMER`）を Git ベース移行ファクトリで Fabric Warehouse へ移送する手順を、再現可能な単位で示す。デモでは「シーン 3: Pull Request と品質ゲート」の補助資料として用いる。

## 前提

- GitHub リポジトリ: `fabric-dwh-migration-factory-demo`
- 標準ブランチ命名: `feature/migrate-<domain>-<short-purpose>` 例: `feature/migrate-customer-domain`
- マージ先: `main`（保護ブランチ。最低 1 名の人間レビューと CI 緑色化を required にする）

## ステップ一覧

| # | アクション | 担当 | 成果物・証跡 |
|---|---|---|---|
| 1 | 移行対象オブジェクトを `inventory/dwh_objects.csv` で確認する | 移行エンジニア | 対象行の更新差分 |
| 2 | `feature/migrate-<domain>` ブランチを切る | 移行エンジニア | ブランチ名 |
| 3 | `source_dwh/ddl/` 等に既存 DWH 資材をコミットする | 移行エンジニア | コミット SHA |
| 4 | `docs/copilot_prompt_cards.md` のカードを使って Copilot に変換を依頼する | 移行エンジニア | Chat ログ抜粋を PR 本文に転記 |
| 5 | 生成物を `fabric/warehouse_project/` 配下に保存し、型・制約・予約語の調整を行う | 移行エンジニア | コミット SHA、変更行 |
| 6 | `tests/` 配下に再照合テストを追加・更新する | 移行エンジニア | テスト SQL 行 |
| 7 | `tests/sample_test_results.md` を更新する | 移行エンジニア | テスト結果 Markdown |
| 8 | Pull Request を作成する。`.github/pull_request_template.md` を埋める | 移行エンジニア | PR URL |
| 9 | GitHub Actions の `sql-build` / `data-quality-check` / `security-scan` を確認する | DevOps | CI 緑色化のスクリーンショット |
| 10 | Copilot Code Review のコメントを確認し、必要箇所を修正する | 移行エンジニア | レビューコメントへの返信 |
| 11 | 人間レビュアが PR を承認する | レビュアー | 承認イベント |
| 12 | `main` にマージする | レビュアー | マージコミット SHA |
| 13 | Fabric Dev に SQL を反映する（手動 / pipeline） | Fabric エンジニア | デプロイログ |
| 14 | Dev で再照合テストを実行し、`docs/sample_pr/` 配下に結果を添える | Fabric エンジニア | テスト結果 |
| 15 | Test / Prod への昇格は人間承認ステップを経る | プロジェクトマネージャ | 承認記録 |

## ロールバック

1. Fabric Dev で問題を検出した場合は、まず該当オブジェクトの直前バージョン SQL を `git revert` で main に戻し、Dev で再反映する。
2. Test / Prod でデータ不整合が起きた場合は、`pipelines/*.json` の `rollback_strategy` に従い、失敗パーティションのみ空のまま保全する。先に成功したパーティションを自動で削除しない。
3. ロールバック判断は必ず人間承認とし、判断記録を PR コメントに残す。

## 監査証跡として残すもの

- PR 本文（Purpose, Migration Scope, Copilot-Assisted Work, Validation Evidence, Risks）
- GitHub Actions ジョブの実行結果（job summary に転載済み）
- Copilot Chat ログの要約（Prompt と決定的な出力の抜粋）
- `tests/sample_test_results.md` の更新差分
- Fabric デプロイ画面のスクリーンショット（Fabric 接続デモ時のみ）

## 想定外シナリオ

| 事象 | 一次対応 | エスカレーション先 |
|---|---|---|
| CI が `sql-build` で失敗 | エラーメッセージを確認し、`docs/sql_dialect_mapping.md` を参照して修正 | データ基盤リード |
| CI が `security-scan` で失敗 | 検知パターンを確認し、シークレットや本物データの混入をリポジトリから完全除去 | セキュリティ担当 |
| Copilot 生成物が業務ロジックを変えている | コミットを破棄し、`-- TODO(reviewer):` コメントを残してプロンプトを見直す | 移行リード |
| Fabric Dev 反映でテストが赤色 | `docs/sample_pr/` に再照合結果を添えて PR を再オープン | Fabric リード |
