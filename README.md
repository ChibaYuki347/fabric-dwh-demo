# Fabric DWH Migration Factory Demo

既存DWH（IBM PureData / Netezza想定）を Microsoft Fabric へ統合する流れを、**GitHubを中核とした移行ファクトリ**として運営する姿を顧客に見せるためのデモリポジトリ。

> 既存DWHのFabric統合を、**Gitで管理し、Copilotで加速し、人間がレビューし、Fabricへ安全に反映する。**

本リポジトリには合成・匿名のサンプルデータと、Fabric / GitHub Actions / Copilot 連携の設計ファイルだけが含まれる。本番データ・実顧客識別子・資格情報は一切含まれない。

## デモのストーリー

`docs/architecture.md` の 1 枚図で全体像を、`docs/demo_script.md` の 7 シーン台本（35〜40 分）でテンポを掴むこと。`docs/copilot_prompt_cards.md` のプロンプトをそのまま使えばリハーサル無しでも実演可能。

| シーン | 所要 | 中心資材 |
|---|---:|---|
| 0. オープニング | 3 分 | `docs/architecture.md` |
| 1. 既存 DWH 資産の取り込み | 5 分 | `inventory/`、`source_dwh/` |
| 2. Copilot による変換支援 | 8 分 | `source_dwh/ddl/` → `fabric/warehouse_project/Tables/` |
| 3. Pull Request と品質ゲート | 8 分 | `docs/sample_pr/`、`.github/workflows/` |
| 4. Fabric 反映イメージ | 6 分 | `fabric/`、`pipelines/` |
| 5. API・AI 連携 | 5 分 | `api/openapi.yaml`、`api/src/` |
| 6. クロージング | 5 分 | `docs/poc_plan.md` |

## ディレクトリ案内

| ディレクトリ | 内容 |
|---|---|
| `instructions/docs/` | 本デモの Requirements / Design / Todos（最上位の真実） |
| `source_dwh/` | 既存 DWH 想定の合成 DDL・ビュー・ETL メタ |
| `fabric/warehouse_project/` | Fabric Warehouse 向け T-SQL（Tables / Views / post-deployment） |
| `fabric/lakehouse/` | Bronze → Silver 列マッピング |
| `pipelines/` | Fabric Data Factory パイプライン定義（初期 / パーティション初期 / 差分） |
| `tests/` | 再照合テスト SQL とサンプル結果 |
| `api/` | OpenAPI と FastAPI スタブ、契約テスト |
| `inventory/` | オブジェクト棚卸し、依存マップ、移行複雑度、合成サンプル CSV |
| `docs/` | デモ台本、Runbook、PoC 計画、リスク登録簿、アーキ図、Copilot プロンプトカード、SQL 方言マッピング、サンプル PR キット、オフラインキット |
| `.github/` | Copilot 指示書、PR テンプレ、ワークフロー、対象パス別 instructions |

## デモ前にやること

1. **デモ方式を選ぶ**: `instructions/docs/Design.md` §10 から A / B / C いずれかを決める。初回は A（リポジトリ完結型）推奨。
2. **オフライン対策**: `docs/offline_kit/screenshots_index.md` に従ってスクリーンショットを取得する。R-08 緩和。
3. **Copilot 動作確認**: VS Code で `.github/copilot-instructions.md` が読み込まれることを確認し、`docs/copilot_prompt_cards.md` のカード #1 を 1 回試す。
4. **CI 緑色化**: 本リポジトリを GitHub 上にミラーし、`.github/workflows/` の 3 ジョブが緑になることを確認する。
5. **35〜40 分リハーサル**: `docs/demo_script.md` のシーン 0〜6 を通しで読み合わせる。

## デモ後にやること

- `docs/poc_plan.md` を顧客版に書き換え、6 週間 PoC を提案する。
- `docs/risk_register.md` の `status: open` を確認し、PoC 中の閉じ込みを計画する。
- `instructions/docs/Todos.md` を顧客側 PJ 計画に取り込み、担当・期日を埋める。

## 注意事項

- 本リポジトリは**デモ用**です。`.github/copilot-instructions.md` に書かれた Azure / Fabric リソース名はデモ向けの架空値であり、本番テナントには接続しません。
- 合成データのみを扱います。実顧客情報・実取引・本物のシークレットを混入させないでください。`.github/workflows/security-scan.yml` が CI で検知します。
- 本リポジトリの内容は移行手順の**雛形**です。本番運用に投入する前に、`docs/sql_dialect_mapping.md` を顧客 DWH の方言に合わせて拡張し、`tests/` の閾値を業務側と合意してください。
