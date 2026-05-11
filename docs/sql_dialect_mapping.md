# SQL 方言マッピング（Netezza → Fabric Warehouse T-SQL）

本ドキュメントは、`.github/instructions/sql-migration.instructions.md` から参照される、Netezza 想定 SQL から Fabric Warehouse（T-SQL）への変換規約の要約である。Copilot 生成物のレビュー観点と、PR コメントでの根拠提示に用いる。

> 注: Fabric Warehouse は T-SQL のサブセットであり、SQL Server / Synapse 専用機能の一部はサポートされない。最新情報は Microsoft Learn の Fabric Warehouse ドキュメントで確認すること。本表はデモ目的の指針であり、PoC 中に検出した差分は本ファイルへ追記する。

## データ型マッピング

| Netezza 側 | Fabric Warehouse 側 | 補足 |
|---|---|---|
| `INTEGER` | `INT` | 32 bit |
| `BIGINT` | `BIGINT` | 64 bit |
| `SMALLINT` | `SMALLINT` | 16 bit |
| `BYTEINT` | `TINYINT` | 符号無し 0-255、Netezza 側は -128〜127 のため範囲確認 |
| `NUMERIC(p,s)` | `DECIMAL(p,s)` | 精度・小数位を必ず維持 |
| `DOUBLE` | `FLOAT(53)` | 浮動小数点は集計に用いない方針を推奨 |
| `CHAR(n)` | `CHAR(n)` | 末尾空白の扱いに注意 |
| `VARCHAR(n)` | `VARCHAR(n)` | n は維持 |
| `NCHAR / NVARCHAR` | `NCHAR / NVARCHAR` | n は維持 |
| `DATE` | `DATE` | 同等 |
| `TIME` | `TIME(6)` | 秒精度を確認 |
| `TIMESTAMP` | `DATETIME2(6)` | UTC 保持を前提 |
| `TIMESTAMP WITH TIME ZONE` | `DATETIMEOFFSET(6)` | タイムゾーンを保持する場合 |
| `BOOLEAN` | `BIT` | TRUE/FALSE → 1/0 |
| `INTERVAL` | （直接対応なし） | 期間値は `DATEADD` 等で表現 |
| `ST_*` 空間型 | （未対応） | Lakehouse 側で扱う、または除外 |

## 構文・クローズ

| Netezza 側 | Fabric Warehouse 側 | 補足 |
|---|---|---|
| `DISTRIBUTE ON (...)` | **削除** | コメントで削除理由を残す |
| `ORGANIZE ON (...)` | **削除** | 同上 |
| `PRIMARY KEY (...)` | 制約として記述するが**強制されない** | デモでは省略しコメントで明示 |
| `CREATE TABLE ... AS SELECT` (CTAS) | `CREATE TABLE` + `INSERT INTO ... SELECT` | CTAS は限定対応、明示的に分離 |
| `LIMIT n` | `TOP (n)` | `OFFSET ... FETCH NEXT` も併用可 |
| `STRPOS(a, b)` | `CHARINDEX(b, a)` | 引数順に注意 |
| `SUBSTR(s, p, l)` | `SUBSTRING(s, p, l)` | 同等 |
| `NVL(a, b)` | `ISNULL(a, b)` | `COALESCE` でも可 |
| `DATE_PART('day', d)` | `DATEPART(day, d)` | 単位文字列のクォート不要 |
| `AGE(t1, t2)` | `DATEDIFF(day, t2, t1)` | 単位を明示 |
| `NOW()` / `CURRENT_TIMESTAMP` | `SYSUTCDATETIME()` | UTC 統一のため |
| `CURRENT_DATE` | `CAST(SYSUTCDATETIME() AS DATE)` | 同上 |
| `SEQUENCE` | **使用しない** | Fabric Warehouse はシーケンス未対応。代替は ETL で発番 |
| `IDENTITY` | **使用しない** | 同上、ETL 発番を推奨 |
| `MERGE INTO ... USING ...` | 限定対応。`INSERT` + `UPDATE` に分割推奨 | 同時実行リスクに注意 |
| `||`（文字列連結） | `+` または `CONCAT(...)` | NULL の挙動に差があるため `CONCAT` 推奨 |
| `~` 正規表現 | `LIKE` か CLR 不要、`PATINDEX` 等 | 正規表現は ETL 側に寄せる |
| `LIMIT ALL` | （直接対応なし） | クエリを書き換える |

## 予約語・命名

- `TRANSACTION` は T-SQL 予約語。`dbo.[Transaction]` のように角括弧でクォートする。
- スキーマは `dbo` を既定とする。Netezza 側の `CORE` / `MART` は target では明示的に `dbo` に統合し、論理的な区別は命名 prefix（`Fact*` / `Dim*` / `Vw_*`）で示す（PoC で命名規約を確定）。
- 列名は PascalCase（`CustomerId`、`UpdatedAt`）を Fabric Warehouse 側の既定とする。

## NULL とゼロ件処理

- Netezza では `NULL` を `0` と暗黙的に比較しない箇所が一部ある。Fabric Warehouse でも厳密に `IS NULL` / `IS NOT NULL` を使う。
- `COUNT(*)` を高頻度列で使う場合、結果が `INT` の範囲を超える可能性があるため `COUNT_BIG(*)` を採用する。
- `SUM` の対象が全 `NULL` の場合は `NULL` が返るため、`COALESCE(SUM(...), 0)` を業務要件に応じて適用する。

## トランザクション・ロック

- Fabric Warehouse は OLAP 寄りで、長時間の明示的トランザクション保持は推奨されない。ETL は冪等な upsert で書く。
- 既存 DWH に存在する `LOCK TABLE` 等の構文は移行しない。代替として ETL の制御フローで排他を確保する。

## レビューで必ず確認する項目

1. `DISTRIBUTE ON` / `ORGANIZE ON` / `SEQUENCE` / `IDENTITY` が残っていないか。
2. `TIMESTAMP` → `DATETIME2(6)`、`NUMERIC` → `DECIMAL` の精度維持。
3. 予約語クォート（`[Transaction]` 等）。
4. `COUNT(*)` を `COUNT_BIG(*)` にすべき箇所（`tests/aggregate_reconciliation.sql` のような件数集計）。
5. `SYSUTCDATETIME()` 前提のタイムゾーン統一。
6. テスト未生成の警告（`tests/` 配下にペアとなる SQL があるか）。

## 改訂履歴

- 2026-05-11: 初版。デモ用に主要マッピングのみ整理。
- 追記時は新しい日付で行を追加し、影響のある instructions ファイル名を併記すること。
