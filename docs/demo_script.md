# デモ進行台本（35〜40 分）

本台本は、`instructions/docs/Design.md` 第 2 章の 7 シーン構成を、35〜40 分で完走するための実演手順である。各シーンには、開く資材、画面で示すポイント、顧客に届けるメッセージを書いている。デモ担当者は、台本どおりに 1 度通しでリハーサルしてから本番に臨むこと。

## 全体像

| # | シーン | 所要 | 主な開く資材 |
|---|---|---:|---|
| 0 | オープニング | 3 分 | `docs/architecture.md` |
| 1 | 既存 DWH 資産の取り込み | 5 分 | `inventory/`, `source_dwh/` |
| 2 | Copilot による変換支援 | 8 分 | `source_dwh/ddl/nz_customer.sql` → `fabric/warehouse_project/Tables/dbo.Customer.sql` |
| 3 | Pull Request と品質ゲート | 8 分 | `docs/sample_pr/`, GitHub Actions 画面 |
| 4 | Fabric 反映イメージ | 6 分 | `fabric/warehouse_project/`, `pipelines/` |
| 5 | API 化・AI 連携 | 5 分 | `api/openapi.yaml`, `api/src/branch_balance_api.py` |
| 6 | クロージング | 5 分 | `docs/poc_plan.md` |

## シーン 0: オープニング（3 分）

`docs/architecture.md` の Mermaid 図を表示する。「既存 DWH を個別作業で移行するのではなく、Git を中心とした移行ファクトリとして運営する」という一文を最初に置く。技術詳細には踏み込まず、登場人物（既存 DWH、GitHub、Copilot、Fabric、Power BI / AI）の関係だけを伝える。

> 締めの一言: 「移行作業を、人に依存した個別作業から、Git で管理される標準作業へ変える、というのが本日の主題です。」

## シーン 1: 既存 DWH 資産の取り込み（5 分）

1. `inventory/dwh_objects.csv` を開き、CUSTOMER / ACCOUNT / TRANSACTION / BRANCH / VW_BRANCH_BALANCE / DAILY_BALANCE / DAILY_BALANCE_JOB を見せる。
2. `inventory/dependency_map.md` で依存関係を、`inventory/migration_complexity.md` で複雑度を 1 画面ずつ説明する。
3. `source_dwh/ddl/nz_customer.sql` と `source_dwh/views/vw_branch_balance.sql` を開く。「これらは既存 DWH から抽出された資産です。Git に置くことで、誰が何をいつ変えたかが追跡できます」と説明する。

> ポイント: 棚卸しが先で、変換はそのあと。これは Copilot を使う前の必須工程である、と強調する。

## シーン 2: Copilot による変換支援（8 分）

1. `source_dwh/ddl/nz_customer.sql` を開いた状態で VS Code の Copilot Chat を呼ぶ。
2. `docs/copilot_prompt_cards.md` のカード #1（DDL 変換）をそのまま貼り付ける。
3. 生成結果を `fabric/warehouse_project/Tables/dbo.Customer.sql` と並べて差分を見せる。`DISTRIBUTE ON` が消えたこと、`TIMESTAMP` が `DATETIME2(6)` に変換されたこと、`PRIMARY KEY` 句が省かれていることをコメントで指摘する。
4. 同じ要領で `vw_branch_balance.sql` → `dbo.vw_BranchBalance.sql` のレビューをカード #2 で依頼する。`TRANSACTION` が予約語であることを Copilot が指摘するかを実演する。
5. その後、カード #3（テスト生成）で `tests/row_count_reconciliation.sql` 等を生成する流れを見せる。

> 強調点: 「生成結果は **下書き** です。人間が型・制約・性能を確認して初めて、Fabric Warehouse に反映できます」。

## シーン 3: Pull Request と品質ゲート（8 分）

1. `docs/sample_pr/pr_description.md` を開き、PR 本文の構造（Purpose / Scope / Copilot-Assisted Work / Validation Evidence / Risks）を 1 分で読み上げる。
2. `docs/sample_pr/copilot_review_comments.md` を開き、Copilot Code Review が出す典型コメント（破壊的 DDL の検出、未検証の型変換、テスト不足、性能リスク）を見せる。Copilot レビューは一次レビューであり、人間レビューを置き換えないと明言する。
3. GitHub Actions の `sql-build.yml` / `data-quality-check.yml` / `security-scan.yml` を切り替え、PR でどのチェックが走るかを示す。`tests/sample_test_results.md` の表が Actions サマリに転載されることを見せる。
4. PR テンプレート（`.github/pull_request_template.md`）の Validation Evidence チェックリストを示し、「証跡を残してから merge する」運用イメージを伝える。

> 強調点: 「Copilot は一次レビューを高速化する。最終承認は人間が責任を持つ」。

## シーン 4: Fabric 反映イメージ（6 分）

1. `fabric/warehouse_project/Tables/`、`Views/`、`post-deployment/security.sql` をディレクトリツリーで見せる。SQL database project と同じ構造であり、Fabric の Git 連携で取り込める形式だと説明する。
2. `pipelines/initial_load_customer.json`、`pipelines/initial_load_transaction_partitioned.json`、`pipelines/delta_load_watermark.json` を開く。初期ロードは月次パーティション、差分ロードは `UPDATED_AT` ウォーターマーク、という設計指針を 30 秒で説明する。
3. `fabric/lakehouse/bronze_to_silver_mapping.md` を開き、Bronze → Silver の列マッピングと品質ゲートを示す。Fabric 環境が手元にある場合は、Fabric Workspace の Git 連携画面に切り替える。

> 強調点: 「Git 上の SQL と JSON が、そのまま Fabric の実装資産になる」。

## シーン 5: API 化・AI 連携（5 分）

1. `api/openapi.yaml` を開き、`/branch-balances` の入出力を読み上げる。Fabric の curated view のみ公開し、生テーブルは公開しない方針を説明する。
2. `api/src/branch_balance_api.py` を開く。FastAPI スタブが Fabric Warehouse の curated 出力をモデル化していることを示し、本実装では Entra ID 認証を前提にすることに触れる。
3. `api/tests/test_branch_balance_api.py` を開き、契約テストの形を見せる。

> 強調点: 「DWH 統合は終点ではない。API と AI エージェントが安全に使えるデータ基盤の出発点である」。

## シーン 6: クロージング（5 分）

1. `docs/poc_plan.md` を開き、6 週間 PoC の週次成果物を読み上げる。
2. `docs/risk_register.md` の上位 3 リスクと緩和策に触れる。
3. 次アクションを 3 つに絞って提示する: (a) PoC 対象ドメインの選定、(b) 既存 DWH 資産の Git 取り込み、(c) Fabric Dev 環境の可用性確認。

> 締めの一言: 「Git で管理し、Copilot で加速し、人間がレビューし、Fabric へ安全に反映する。これを PoC で実証しましょう」。

## 質疑応答に備える

- 「実環境がなくても進められるか」: `docs/offline_kit/` を参照しスクリーンショット代替で進められると説明する。
- 「Copilot が誤変換した場合の責任分界」: Copilot は一次変換、最終判断は人間、と明示する。`tests/` と CI が安全網になる。
- 「金融機関での説明責任」: PR とレビューコメント、CI 結果、`docs/runbook.md` の証跡がそのまま監査資料になる。

## デモ終了後のアウトプット

- 顧客へ送る成果物: `instructions/docs/Requirements.md`、`instructions/docs/Design.md`、`instructions/docs/Todos.md`、`docs/poc_plan.md`、本リポジトリの URL。
- 内部レビュー資料: 本台本に加え、当日のリハーサル所要時間と Q&A メモを別途残す。
