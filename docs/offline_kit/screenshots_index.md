# オフラインキット: スクリーンショット index

Fabric 環境やネットワークが当日利用できないリスク（R-08）に備え、必要なスクリーンショットを事前に取得しておく。本ファイルは取得対象と保管場所の索引である。実画像は本リポジトリには含めず、デモ担当者の手元または社内ファイルサーバで管理する（実画像にメタデータ・閲覧者情報が含まれる可能性があるため）。

## 取得対象一覧

| # | 画面 | 取得方法 | デモシーン | 保管場所（推奨） |
|---|---|---|---|---|
| 1 | GitHub リポジトリトップ（ファイル構造） | Web | 1 | `\\fileserver\fabric-demo\shots\01-repo-tree.png` |
| 2 | `inventory/dwh_objects.csv` のテーブル表示 | Web | 1 | `02-inventory-csv.png` |
| 3 | `source_dwh/ddl/nz_customer.sql` のコードビュー | VS Code | 1-2 | `03-source-ddl.png` |
| 4 | Copilot Chat に カード #1 を貼った時の応答 | VS Code | 2 | `04-copilot-ddl-conversion.png` |
| 5 | `fabric/warehouse_project/Tables/dbo.Customer.sql` のコードビュー | VS Code | 2 | `05-fabric-target.png` |
| 6 | Copilot Chat に カード #2 を貼った時のレビュー指摘 | VS Code | 2 | `06-copilot-view-review.png` |
| 7 | Pull Request 一覧 | Web | 3 | `07-pr-list.png` |
| 8 | PR の Conversation タブ（PR 本文 + Copilot レビューコメント） | Web | 3 | `08-pr-conversation.png` |
| 9 | PR の Files Changed タブ（diff） | Web | 3 | `09-pr-files.png` |
| 10 | PR の Checks タブ（Actions 3 種すべて緑） | Web | 3 | `10-pr-checks.png` |
| 11 | `data-quality-check.yml` の job summary（sample_test_results.md 転載） | Web | 3 | `11-actions-summary.png` |
| 12 | `pipelines/initial_load_transaction_partitioned.json` のコードビュー | VS Code | 4 | `12-pipeline-partitioned.png` |
| 13 | Fabric Workspace のトップ（環境ありの場合） | Web | 4 | `13-fabric-workspace.png` |
| 14 | Fabric Warehouse の Git 連携画面（環境ありの場合） | Web | 4 | `14-fabric-git-sync.png` |
| 15 | `api/openapi.yaml` を Swagger UI で表示 | Web | 5 | `15-openapi-swagger.png` |
| 16 | `api/src/branch_balance_api.py` の `/branch-balances` ハンドラ | VS Code | 5 | `16-api-code.png` |
| 17 | `docs/poc_plan.md` の週次表 | VS Code or Web | 6 | `17-poc-table.png` |
| 18 | `docs/architecture.md` の Mermaid 図レンダリング | VS Code Markdown Preview | 0 | `18-architecture.png` |

## 取得時のチェック

- Web 画面取得時は、ブラウザの個人プロファイル名・通知バッジが映り込まないようにする。プロファイルアイコンはダミー化するか黒塗りする。
- VS Code のサイドバーに無関係なファイルが見えないように、デモ用ワークスペースで取得する。
- 個人メールアドレスやテナント名（`*.onmicrosoft.com`）が映る画面は、デモ用テナントで撮り直すか、画像エディタでマスクする。
- 画像形式は PNG、解像度は 1920x1080 以上を推奨。

## オフライン進行時の入れ替え方

1. 本来の操作の代わりに、上記スクリーンショットをスライドで投影する。
2. `docs/offline_kit/talking_points.md` のフレーズを、各画像のキャプションとして読み上げる。
3. 質疑応答で「実画面が見たい」と要望があれば、PoC で別途デモ環境を準備する旨を伝える。
