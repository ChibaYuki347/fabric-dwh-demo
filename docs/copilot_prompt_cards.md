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
- **開いておくファイル**: `source_dwh/ddl/nz_customer.sql`
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
- **開いておくファイル**: `source_dwh/views/vw_branch_balance.sql`、`fabric/warehouse_project/Views/dbo.vw_BranchBalance.sql`
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
- **開いておくファイル**: `fabric/warehouse_project/Tables/dbo.Customer.sql`、`tests/row_count_reconciliation.sql`
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
- **開いておくファイル**: `api/openapi.yaml`、`fabric/warehouse_project/Views/dbo.vw_BranchBalance.sql`
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

## 運用メモ

- 上記カードのうち、デモ本番では #1, #2, #5 を必ず使う。残りは時間に余裕があるときの拡張デモとして扱う。
- 顧客が「Copilot は何でもできるのか」と質問してきた場合は、各カードの「constraints」セクションを指差し、**ガードレールを書くから安定する**と説明する。
- カードは生成 AI モデルの更新で挙動が変わる可能性があるため、PoC 各週の最後に動作確認を行い、本ファイルを差分で更新する。
