# Fabric DWH Migration Factory Demo

既存DWH（IBM PureData / Netezza想定）を Microsoft Fabric へ統合する流れを、**GitHubを中核とした移行ファクトリ**として運営する姿を示すデモリポジトリ。

> 既存DWHのFabric統合を、**Gitで管理し、Copilotで加速し、人間がレビューし、Fabricへ安全に反映する。**

本リポジトリには合成・匿名のサンプルデータと、Fabric / GitHub Actions / Copilot 連携の設計ファイルだけが含まれる。本番データ・実顧客識別子・資格情報は一切含まれない。

## デモのストーリー

`docs/architecture.md` の 1 枚図で全体像を、`docs/copilot_prompt_cards.md` のプロンプトをそのまま使えば Copilot 実演ができる。Netezza → Fabric T-SQL の方言差分は `docs/sql_dialect_mapping.md`、PoC への接続は `docs/poc_plan.md` を参照。

| シーン | 中心資材 |
|---|---|
| 0. オープニング | `docs/architecture.md` |
| 1. 既存 DWH 資産の取り込み | `inventory/`、`source_dwh/` |
| 2. Copilot による変換支援 | `source_dwh/ddl/` → `fabric/warehouse_project/Tables/` |
| 3. Pull Request と品質ゲート | `.github/workflows/`、`.github/pull_request_template.md` |
| 4. Fabric 反映イメージ | `fabric/`、`pipelines/` |
| 5. API・AI 連携 | `api/openapi.yaml`、`api/src/` |
| 6. クロージング | `docs/poc_plan.md` |

## ディレクトリ案内

| ディレクトリ | 内容 |
|---|---|
| `source_dwh/` | 既存 DWH 想定の合成 DDL・ビュー・ETL メタ |
| `fabric/warehouse_project/` | Fabric Warehouse 向け T-SQL（Tables / Views / post-deployment） |
| `fabric/lakehouse/` | Bronze → Silver 列マッピング |
| `pipelines/` | Fabric Data Factory パイプライン定義（初期 / パーティション初期 / 差分） |
| `tests/` | 再照合テスト SQL とサンプル結果 |
| `api/` | OpenAPI と FastAPI スタブ、契約テスト |
| `inventory/` | オブジェクト棚卸し、依存マップ、移行複雑度、合成サンプル CSV |
| `docs/` | アーキ図、Copilot プロンプトカード、SQL 方言マッピング、PoC 計画 |
| `.github/` | Copilot 指示書、PR テンプレ、ワークフロー、対象パス別 instructions |

## CI ワークフロー

| Workflow | 目的 |
|---|---|
| `.github/workflows/sql-build.yml` | 危険 DDL の検知、Netezza 方言の漏れ検知、Fabric T-SQL 衛生チェック、棚卸し CSV のヘッダ固定 |
| `.github/workflows/data-quality-check.yml` | 合成 CSV のヘッダ整合性、再照合テスト SQL の存在確認 |
| `.github/workflows/security-scan.yml` | シークレットパターン検知、PII 語彙検知、Copilot 指示書の存在確認 |

すべて `pull_request` と `workflow_dispatch` で起動する。Copilot との連携は `.github/copilot-instructions.md` と `.github/instructions/*.instructions.md` が定義する。

## 注意事項

- 本リポジトリは**デモ用**です。`.github/copilot-instructions.md` に書かれた Azure / Fabric リソース名はデモ向けの架空値であり、本番テナントには接続しません。
- 合成データのみを扱います。実顧客情報・実取引・本物のシークレットを混入させないでください。`.github/workflows/security-scan.yml` が CI で検知します。
- 本リポジトリの内容は移行手順の**雛形**です。本番運用に投入する前に、`docs/sql_dialect_mapping.md` を顧客 DWH の方言に合わせて拡張し、`tests/` の閾値を業務側と合意してください。
