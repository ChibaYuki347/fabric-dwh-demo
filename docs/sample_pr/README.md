# サンプル PR キット

`feature/migrate-customer-domain` ブランチで開いたサンプル Pull Request の本文・Copilot Code Review コメント・差分要約を、デモのシーン 3 で投影するための資材一式。実 PR がなくても、本ディレクトリの 3 ファイルをスクリーンに出せば、PR 画面を「再現」できる。

## ファイル一覧

| ファイル | 役割 | シーン 3 のどこで使うか |
|---|---|---|
| `pr_description.md` | PR 本文を `.github/pull_request_template.md` に沿って埋めた完成例 | PR の Conversation タブ冒頭を読み上げる |
| `copilot_review_comments.md` | Copilot Code Review が出す典型コメントの例 | レビューコメント欄を再現するときに参照 |
| `diff_summary.md` | 主な変更ファイルと変更点のサマリ | Files Changed タブ代わりに投影 |

## 想定 PR メタ情報

- ブランチ: `feature/migrate-customer-domain`
- ベース: `main`
- 作者: 移行エンジニア（PoC 担当）
- レビュアー: データ基盤リード、Fabric エンジニア
- ラベル: `migration`, `customer-domain`, `needs-fabric-review`
- CI: `sql-build` / `data-quality-check` / `security-scan` すべて緑
