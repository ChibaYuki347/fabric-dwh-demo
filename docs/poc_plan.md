# 6 週間 PoC 計画

本計画は、デモ実施後に顧客と合意する「代表領域での Git ベース移行ファクトリ PoC」のためのテンプレートである。実プロジェクトでは、顧客側体制、Fabric 環境の可用性、移行対象スコープを反映して微調整する。

## 全体ゴール

代表業務ドメイン（例: 顧客 / 口座 / 取引 / 支店残高）を対象に、Git ベース移行ファクトリのプロセスと成果物を実証する。本番移行に着手する前に、テンプレート化された移行フローを確立し、量産移行の見積もり根拠とする。

## 体制（推奨）

| ロール | 想定担当 | 主な責務 |
|---|---|---|
| プロジェクトマネージャ | 顧客側 | スコープ、意思決定、リスク管理 |
| データ基盤リード | 顧客 + パートナー | SQL 変換、Fabric Warehouse 設計 |
| ETL / パイプラインリード | 顧客 + パートナー | 初期 / 差分ロード、ウォーターマーク設計 |
| 品質 / 監査 | 顧客 | 再照合テスト、PR レビュー、監査証跡 |
| デモ・トレーニング | パートナー | Copilot 活用、移行テンプレート整備 |
| Fabric / Azure 基盤 | 顧客 IT 基盤 + パートナー | Workspace、Warehouse、Pipeline 環境提供 |

## 週次計画

| 週 | ゴール | 主な成果物 | 完了条件 |
|---|---|---|---|
| 1 | 代表業務ドメインの選定と既存資産の棚卸し | `inventory/dwh_objects.csv` 拡充、`inventory/dependency_map.md`、`inventory/migration_complexity.md` | 移行対象 10〜20 オブジェクトの一覧が確定 |
| 2 | 移行ファクトリ scaffold の確立 | リポジトリ、`.github/copilot-instructions.md`、PR テンプレート、Actions、`docs/copilot_prompt_cards.md` | 1 件のサンプル PR が緑色で merge できる |
| 3 | DDL とビューの一次変換 | `fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/`、`Views/` の draft 一式、`docs/sql_dialect_mapping.md` 拡充 | 主要 5 テーブル + 主要 2 ビューが Fabric Warehouse に反映可能 |
| 4 | 初期ロード・差分ロードの実装 | `pipelines/initial_load_*.json`、`pipelines/delta_load_*.json` | 取引系テーブルでパーティション初期ロードと watermark 差分ロードが疎通 |
| 5 | データ品質テストとレビュー運用 | `tests/*.sql`、`tests/sample_test_results.md`、Copilot Code Review 運用ルール | CI 全 3 ワークフローで合計 1 件以上の検知/防止事例を記録 |
| 6 | 量産移行展開計画 | 量産見積、テンプレート集、`docs/poc_plan.md` 更新 | 横展開計画と次フェーズ提案資料が顧客内承認に進める状態 |

## 評価指標（KPI 候補）

| 観点 | 指標 | PoC ゴール |
|---|---|---|
| 速度 | 1 オブジェクト当たりの平均移行リードタイム（PR open → merge） | 3 営業日以内 |
| 品質 | 再照合テストカバレッジ（移行オブジェクトに対する `tests/` 紐付け率） | 100% |
| 統制 | PR レビュー実施率（人間承認の付与率） | 100% |
| 安全 | `security-scan.yml` 失敗の本番混入率 | 0 |
| 知識 | `docs/copilot_prompt_cards.md` 上で確定したプロンプト数 | 6 種以上 |

## 意思決定ゲート

- Week 2 終了時: 移行ファクトリ scaffold をそのまま量産移行で使うか、独自整備するかを判定する。
- Week 4 終了時: Fabric Workspace / Warehouse の容量・権限が本番要件に耐えるかを判定する。
- Week 6 終了時: 量産移行の体制・スケジュール・予算を合意する。

## デモから PoC への引き継ぎチェックリスト

- [ ] デモリポジトリ（本リポジトリ）を顧客テナントの GitHub 組織にフォーク／コピーする
- [ ] `.github/copilot-instructions.md` の Azure / Fabric リソース名を顧客環境に書き換える
- [ ] Fabric Workspace `demo-fabric-dwh-ws` を顧客の Dev / Test / Prod に対応する Workspace に置き換える
- [ ] GitHub Actions の Environments を `dev` / `test` / `prod` で作成し、承認者を割り当てる
- [ ] 顧客側レビュアと、パートナー側支援メンバーの権限を Org / Repo レベルで整理する
