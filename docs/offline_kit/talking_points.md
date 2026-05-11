# オフライン Talking Points

ネットワーク不調・Fabric 環境停止・Copilot 応答遅延などで実演を中断するリスク（R-08, R-11）に備えた、シーン別の話法カンペ。各シーンで本ファイルを横に置き、画面が出ない時はそのまま読み上げて時間を埋める。

## オープニング

> 既存 DWH の Fabric 統合は、これまで担当者ごとに設計・変換・検証・移行手順が分散しがちでした。本日のデモでは、その作業を Git で管理し、GitHub Copilot で加速し、Pull Request と CI で品質を担保し、Microsoft Fabric へ安全に反映する一連の流れを、移行ファクトリとしてお見せします。

## シーン 1（既存 DWH 資産の取り込み）

- 棚卸しが先で、変換はそのあと。
- `inventory/dwh_objects.csv` のような表があるだけで、移行対象の見える化と優先順位が顧客全体で揃う。
- 既存資産は `source_dwh/` のように Git に置く。これだけで「いつ・誰が・なぜ」変えたかが追跡できる。

> 補足: 「実 DWH への接続は本デモではしません。合成サンプルだけで進めますので、機微情報の混入リスクはゼロです」。

## シーン 2（Copilot による変換支援）

- Copilot は補完ではなく、移行作業の「初期ドラフト製造機」と捉える。
- カード #1 で DDL を変換するときに重要なのは、`.github/copilot-instructions.md` と `sql-migration.instructions.md` を Copilot が前提として参照していること。
- ガードレール（指示書）を書くから出力が安定する、というのが Copilot 活用の本質。
- 変換結果は **下書き**。型・制約・性能は人間が確認する。

> Q「Copilot が誤変換した場合の責任は」→ A「最終判断は人間です。Copilot は一次変換、テストと PR レビューが安全網になります」。

## シーン 3（PR と品質ゲート）

- PR テンプレートが Purpose / Migration Scope / Copilot-Assisted Work / Validation Evidence / Risks を強制する。
- CI 3 種（sql-build / data-quality-check / security-scan）が、方言・テスト・シークレットを自動チェック。
- Copilot Code Review は一次レビューで、人間レビューを置き換えない。`sample_pr/copilot_review_comments.md` のサンプルが示すように、危険 DDL や型損失といった機械的検出が中心。
- 監査資料として、PR + CI + テスト結果がそのまま残る。

> Q「金融機関の監査に耐えるか」→ A「PR のタイムスタンプ、レビュー署名、CI 結果、テスト結果が、そのまま証跡になります。`docs/runbook.md` に手順を書いています」。

## シーン 4（Fabric 反映イメージ）

- `fabric/warehouse_project/` は SQL database project の標準構造に揃えており、Fabric の Git 連携でそのまま取り込める。
- パイプラインは初期ロードと差分ロードを分離。取引のような大量テーブルは月次パーティションで初期ロード（`initial_load_transaction_partitioned.json`）。
- Lakehouse の Bronze → Silver マッピング（`fabric/lakehouse/bronze_to_silver_mapping.md`）も Git で版管理される。
- 環境がある場合は Fabric Workspace 画面、ない場合は `docs/offline_kit/screenshots_index.md` の 13/14 番を投影。

> Q「Fabric 容量がまだ確保できていない」→ A「Git 上の成果物だけでも、移行ファクトリの運用整備は始められます。PoC Week 2 の意思決定ゲートで容量と権限を確認しましょう」。

## シーン 5（API・AI 連携）

- 公開は curated view のみ。生テーブルは API から見せない。
- OpenAPI 先行、実装は後追い。`api/tests/test_branch_balance_api.py` のような契約テストが Fabric 接続の有無に関係なく回る。
- AI エージェントはこの API を介して安全にデータへアクセスする。RAG・コパイロット業務拡張の足場になる。

> Q「AI から DWH の生データを直接叩かないのか」→ A「叩かせません。curated 層 + OAuth2 で抽象化し、監査と権限制御を効かせます」。

## シーン 6（クロージング）

- 6 週間 PoC では、代表ドメインの移行を実際に通す。Week 2 で運用ガードレールが完成、Week 6 で量産展開計画。
- 次アクションは 3 つ: 対象ドメイン選定、既存資産取り込み、Fabric Dev 環境確認。
- Copilot のライセンスや Fabric の SKU は、PoC 開始前にお見積もり可能。

> 締めの一言: 「Git で管理し、Copilot で加速し、人間がレビューし、Fabric へ安全に反映する。これを PoC で実証しましょう」。

## 万一のリカバリ

- ネットワーク途絶: スクリーンショットモードに切り替え（`screenshots_index.md` の #1〜#18）。
- Copilot 応答遅延: 該当シーンを 1〜2 分で切り上げ、`copilot_prompt_cards.md` のプロンプト文だけ読み上げて先へ進む。
- 質問が長引く: クロージングを優先し、未回答の質問は当日 1on1 または翌日メールで対応する旨を約束する。
- VS Code クラッシュ: ブラウザで GitHub Web を開き、`source_dwh/`、`fabric/`、`tests/` をファイル一覧として見せて進行する。
