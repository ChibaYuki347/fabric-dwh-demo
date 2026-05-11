# Copilot プロンプトカード

デモ実演中に Copilot Chat へ貼り付けるプロンプトを、用途別にカード化したものである。デモ担当者は本ファイルから順にコピー&ペーストすれば、実演の流れを再現できる。

各カードは次の構造をとる:
- **目的**: そのプロンプトでデモのどのシーンを支援するか
- **開いておくファイル**: Copilot が文脈を取り込むために事前に開いておくファイル
- **プロンプト本文**: そのまま Copilot Chat に貼る
- **見せ場**: 生成結果のどこを観客に指差して説明するか

---

## カード #1: Netezza DDL を Fabric Warehouse T-SQL に変換

- **目的**: シーン 2 の最初の変換実演。
- **開いておくファイル**: `source_dwh/ddl/nz_customer.sql`、`fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/Customer.sql`（出力先の見本）
- **プロンプト本文**:

```text
You are assisting a Fabric DWH migration demo.
Convert the open Netezza-style DDL into Fabric Warehouse-compatible T-SQL.

Constraints:
- Follow .github/copilot-instructions.md and .github/instructions/sql-migration.instructions.md.
- Drop DISTRIBUTE ON. Add a SQL comment explaining the removal.
- Map TIMESTAMP to DATETIME2(6), NUMERIC(p,s) to DECIMAL(p,s).
- Do not emit a PRIMARY KEY clause; Fabric Warehouse does not enforce PKs.
- Quote reserved words (e.g. dbo.[Transaction]).
- Keep column order identical to the source.
- Output only T-SQL inside a code block, plus a short bullet list of mapping decisions below it.
```

- **見せ場**:
  - `DISTRIBUTE ON` が消えていること
  - `DATETIME2(6)` への変換
  - `PRIMARY KEY` が省かれたこと

---

## カード #2: ビュー SQL を Fabric 互換にレビュー

- **目的**: シーン 2 中盤。Copilot がレビュー観点を提示することを見せる。
- **開いておくファイル**: `source_dwh/views/vw_branch_balance.sql`、`fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Views/vw_BranchBalance.sql`
- **プロンプト本文**:

```text
Review the open view SQL pair (Netezza source vs Fabric target).
Surface anything that could break in Fabric Warehouse: reserved words, SELECT *,
implicit casts, NULL handling, performance for high-volume joins on dbo.[Transaction],
and missing reconciliation tests in tests/.

Format the answer as:
1. Findings (file:line, severity, fix suggestion)
2. Recommended tests to add or update
3. Open questions for the human reviewer
```

- **見せ場**:
  - `TRANSACTION` が予約語であることを指摘
  - `COUNT(*)` → `COUNT_BIG(*)` の助言
  - 大量 JOIN の性能観点

---

## カード #3: 再照合テストを生成

- **目的**: シーン 3 直前。Copilot にテスト生成を依頼する。
- **開いておくファイル**: `fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/Customer.sql`、`tests/row_count_reconciliation.sql`
- **プロンプト本文**:

```text
Generate the reconciliation SQL the demo needs for dbo.Customer:
1. Row count reconciliation between source (CORE.CUSTOMER) and target (dbo.Customer).
2. Aggregate reconciliation on RiskScore SUM (use DECIMAL(18,2)).
3. Key uniqueness check on CustomerId.
4. NULL rate check on CustomerSegment and RiskScore.

Follow .github/instructions/sql-migration.instructions.md. Output as separate SQL files
ready to drop under tests/. Add a one-line comment at the top of each file explaining
the threshold and which check from tests/sample_test_results.md it maps to.
```

- **見せ場**:
  - テストが「threshold つきで」生成される点
  - `tests/sample_test_results.md` と紐づくこと

---

## カード #4: Fabric Data Factory Pipeline を設計

- **目的**: シーン 4 のパイプライン説明。
- **開いておくファイル**: `pipelines/delta_load_watermark.json`、`pipelines/initial_load_transaction_partitioned.json`
- **プロンプト本文**:

```text
Propose a delta load pipeline definition for dbo.[Transaction] following
.github/instructions/pipeline.instructions.md.
- Use UPDATED_AT as the watermark column.
- Reference Key Vault kv-dwh-demo for credentials.
- Add a rollback_strategy paragraph.
- Add a retry_policy with exponential backoff (max 3 attempts).
- Output strictly JSON, matching the style of pipelines/delta_load_watermark.json.
```

- **見せ場**:
  - Key Vault 参照が必須化されていること
  - rollback_strategy と retry_policy が必ず含まれること

---

## カード #5: Pull Request 本文を生成

- **目的**: シーン 3 の PR レビュー実演で、Copilot が PR 本文を草案するところを見せる。
- **開いておくファイル**: `.github/pull_request_template.md`、対象の diff
- **プロンプト本文**:

```text
Draft this PR's body using the repo template at .github/pull_request_template.md.
Focus on:
- Migration Scope: list source/target objects from the diff.
- Copilot-Assisted Work: cite the prompt cards used (docs/copilot_prompt_cards.md).
- Validation Evidence: tick only the checks actually run; leave the others unchecked.
- Risks and Rollback: include a 3-sentence risk summary and a concrete revert step.
- Out of Scope: enumerate at least one item.

Write in Japanese for narrative sections (Purpose, Risks, Out of Scope) and keep
file paths / commands in English.
```

- **見せ場**:
  - PR テンプレ各セクションが Copilot で 30 秒で埋まること
  - Validation Evidence が「未実施を勝手にチェックしない」点

---

## カード #6: 支店残高 API の OpenAPI を生成

- **目的**: シーン 5 の API 化説明。
- **開いておくファイル**: `api/openapi.yaml`、`fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Views/vw_BranchBalance.sql`
- **プロンプト本文**:

```text
Extend api/openapi.yaml with a POST /branch-balances/refresh endpoint that an
AI agent could call to trigger a manual refresh of dbo.DailyBalance via the
pipelines/delta_load_watermark.json pipeline.

Constraints:
- Follow .github/instructions/api.instructions.md.
- The endpoint must require an OAuth2 bearer token (Entra ID).
- Body: { "businessDate": "YYYY-MM-DD" }
- 202 Accepted with a runId; 400 for missing/invalid date; 401 for unauthorized.
- Do not implement the handler in Python; only update the OpenAPI spec.
```

- **見せ場**:
  - Curated view のみ公開する設計が貫かれていること
  - 認証要件が必ず提示されること

---

---

# ライブデモ用カード（シーン 1 / シーン 2）

ここから下は、**Fabric Workspace が実際に更新される 30 分ライブデモ**専用のカードです。
カード #1〜#6 はストーリーボードや紙芝居でも使えるのに対し、#7〜#9 は当日の `Update from Git` ・Notebook 実行・想定外時の復旧を支援します。

## カード #7: ライブデモ — Netezza → T-SQL 変換 (Scene 1)

- **目的**: ライブデモ前半で、Copilot が変換した T-SQL を実ファイルとして `.Warehouse/Schemas/dbo/Tables/` に作成し、merge して Fabric に反映する流れを起動する。
- **開いておくファイル**: `source_dwh/ddl/nz_account.sql`、`fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/Customer.sql`（出力スタイルの見本）
- **プロンプト本文**:

```text
We are doing a LIVE migration demo. The Fabric Warehouse item lives at
fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/.

Convert the open Netezza DDL (nz_account.sql) into a new file
fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/Account.sql.

Rules:
- Match the file style of Customer.sql exactly: opening "-- Fabric Warehouse target ported from ..."
  comment, then a "Mapping notes" block, then CREATE TABLE dbo.<Name> ( ... ).
- Drop DISTRIBUTE ON; comment that it is removed.
- TIMESTAMP -> DATETIME2(6); NUMERIC(p,s) -> DECIMAL(p,s).
- Do NOT emit a PRIMARY KEY clause.
- Quote reserved words as dbo.[Transaction] only when needed.
- Keep column order identical to the source DDL.

After producing the file, list the exact `git` commands the presenter should
run to create a branch `live/account-table`, commit, push, and open a PR with
`gh pr create`.
```

- **見せ場**:
  - Copilot が**新規ファイルとして書き出す**ところ（コピペではない）。
  - 出力末尾の `git checkout -b live/account-table && git add ... && gh pr create` を、そのままターミナルで実行できる。

---

## カード #8: ライブデモ — PR レビュー (Scene 2)

- **目的**: PR が出た直後、Copilot Code Review コメントを呼び出してから人間レビュアに切り替える流れを実演する。
- **開いておくファイル**: GitHub の PR の "Files changed" タブ
- **プロンプト本文**:

```text
You are the human reviewer for this PR. The PR adds
fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/Account.sql.

Audit the diff with these gates:
1. Mapping correctness vs docs/sql_dialect_mapping.md (DISTRIBUTE ON removed, TIMESTAMP -> DATETIME2(6), NUMERIC -> DECIMAL, no PK).
2. Naming: column order matches source, casing matches existing dbo.* tables in the same folder.
3. Safety: no DROP TABLE / TRUNCATE in the diff (sql-build.yml would block them anyway, but mention it for the audience).
4. Tests: which tests/ files cover dbo.Account? Are thresholds explicit?
5. Fabric Git serialization: are there any files outside fabric/*.Warehouse/Schemas/ that should be in post-deployment/ instead?

Output as a single concise PR review comment in Japanese, with one bullet per gate.
End with one of: "LGTM, merge ready" / "Request changes" / "Need maintainer attention".
```

- **見せ場**:
  - 「Copilot **の出力をレビューしている**のも Copilot」という構図。
  - ガードレールが PR ごとに自動で適用される点。

---

## カード #9: ライブデモ — 想定外時の復旧（フォールバック）

- **目的**: Fabric の `Update from Git` が遅延 / Notebook が cold start でハングした場合に、すぐ次の話題へ繋ぐ。
- **開いておくファイル**: `scripts/local_smoke.py`、本リポジトリの GitHub PR ページ
- **プロンプト本文**:

```text
The Fabric portal is not refreshing within demo time budget (90 seconds).
Switch the audience's attention away from the portal:

1. Run `python scripts/local_smoke.py` and explain that the same checks
   from 02_validate.Notebook are running locally on DuckDB, producing the
   same row counts, key uniqueness, NULL rates, and aggregate reconciliation.
2. Point at the merged PR in GitHub: this is the source of truth; Fabric
   is just one consumer of it. The same merged commit could deploy to a
   dev / test / prod workspace via the same Git integration.
3. Give a one-sentence cue to the audience: 「同期は数分のラグがあります
   が、Git 側の信頼性は今ご覧の CI と Copilot レビューで担保されています。」

Write the three lines as presenter-facing speaker notes in Japanese, plus
the exact shell command for step 1.
```

- **見せ場**:
  - 失敗をリカバリできる構成であること自体が、移行ファクトリの強み。

---

## 運用メモ

- 紙芝居デモ（顧客先 PoC 検討時）では **#1, #2, #5** を必ず使う。
- ライブデモ（30 分版）では **#7 → #8 → (進行が押した時のみ #9)** をシーン 1〜2 で連続使用する。
- 顧客が「Copilot は何でもできるのか」と質問してきた場合は、各カードの「constraints」セクションを指差し、**ガードレールを書くから安定する**と説明する。
- カードは生成 AI モデルの更新で挙動が変わる可能性があるため、PoC 各週の最後に動作確認を行い、本ファイルを差分で更新する。
