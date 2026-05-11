# Bronze → Silver 列マッピング

本ドキュメントは、既存DWH（Netezza想定）から Fabric Lakehouse へ取り込んだ Bronze ゾーンの生データを、Silver ゾーンの正規化済みテーブルへ整形する際の列マッピングおよび変換規約を示す。Gold ゾーンの集計（`dbo.DailyBalance` 等）は `pipelines/delta_load_watermark.json` 側で扱う。

## ゾーンの役割

| ゾーン | 目的 | 主な処理 |
|---|---|---|
| Bronze | 既存DWHからの忠実取り込み | スキーマ無加工、メタ列付与、改廃含むイベント保持 |
| Silver | クレンジング・正規化 | 型変換、NULL 規約、重複排除、参照整合 |
| Gold   | 業務集計・公開 | `vw_BranchBalance` / `DailyBalance` 等の Warehouse オブジェクト |

## 共通変換規約

- 文字コードは UTF-8 に統一する。Bronze 側で発見した不正バイトは `_quarantine/` に退避する。
- タイムスタンプは UTC で保持する。表示側タイムゾーン変換は実施しない。
- 数値は元の精度・小数点位を保つ。`DECIMAL(p,s)` を `DOUBLE` へ寄せ替えてはならない。
- 監査列 `_ingested_at` (DATETIME2) と `_source_file` (VARCHAR) を全 Silver テーブルに付与する。

## テーブル別マッピング

### Customer
| Bronze 列 | 型 | Silver 列 | 型 | 変換規約 |
|---|---|---|---|---|
| CUSTOMER_ID | INTEGER | CustomerId | INT | 主キー。NULL は弾く |
| CUSTOMER_SEGMENT | VARCHAR(20) | CustomerSegment | VARCHAR(20) | TRIM。空文字は NULL に正規化 |
| OPEN_DATE | DATE | OpenDate | DATE | 1900-01-01 未満は NULL |
| RISK_SCORE | NUMERIC(5,2) | RiskScore | DECIMAL(5,2) | 範囲外 (>999.99) は `_quarantine` |
| UPDATED_AT | TIMESTAMP | UpdatedAt | DATETIME2(6) | UTC のまま保持 |

### Account
| Bronze 列 | 型 | Silver 列 | 型 | 変換規約 |
|---|---|---|---|---|
| ACCOUNT_ID | BIGINT | AccountId | BIGINT | 主キー |
| CUSTOMER_ID | INTEGER | CustomerId | INT | `Customer.CustomerId` への参照整合チェック |
| BRANCH_ID | INTEGER | BranchId | INT | `Branch.BranchId` への参照整合チェック |
| ACCOUNT_TYPE | VARCHAR(20) | AccountType | VARCHAR(20) | コード値辞書で許可値のみ通す |
| STATUS_CD | CHAR(1) | StatusCode | CHAR(1) | `A`/`C`/`S` 以外は `_quarantine` |
| OPEN_DATE | DATE | OpenDate | DATE | 同上 |
| UPDATED_AT | TIMESTAMP | UpdatedAt | DATETIME2(6) | UTC のまま |

### Transaction
| Bronze 列 | 型 | Silver 列 | 型 | 変換規約 |
|---|---|---|---|---|
| TRANSACTION_ID | BIGINT | TransactionId | BIGINT | 主キー |
| ACCOUNT_ID | BIGINT | AccountId | BIGINT | `Account.AccountId` 参照整合 |
| TRANSACTION_DATE | DATE | TransactionDate | DATE | 営業日カレンダ照合（休日は警告） |
| AMOUNT | NUMERIC(18,2) | Amount | DECIMAL(18,2) | 精度厳守 |
| CHANNEL_CD | VARCHAR(10) | ChannelCode | VARCHAR(10) | 許可値: `ATM`,`BRANCH`,`ONLINE`,`MOBILE` |
| UPDATED_AT | TIMESTAMP | UpdatedAt | DATETIME2(6) | UTC のまま |

### Branch
| Bronze 列 | 型 | Silver 列 | 型 | 変換規約 |
|---|---|---|---|---|
| BRANCH_ID | INTEGER | BranchId | INT | 主キー |
| BRANCH_NAME | VARCHAR(60) | BranchName | VARCHAR(60) | TRIM |
| REGION_CD | VARCHAR(10) | RegionCode | VARCHAR(10) | 大文字化 |
| OPEN_DATE | DATE | OpenDate | DATE | 同上 |
| STATUS_CD | CHAR(1) | StatusCode | CHAR(1) | `A`/`C` のみ |
| UPDATED_AT | TIMESTAMP | UpdatedAt | DATETIME2(6) | UTC のまま |

## 品質ゲート

- Silver 書き込み時点で `tests/row_count_reconciliation.sql`、`tests/key_uniqueness_check.sql`、`tests/null_rate_check.sql` を必ず実行する。
- いずれかが失敗した場合、Silver 側はトランザクション単位でロールバックし、`_quarantine/` 配下に該当 Bronze バッチを移送する。

## 未確定事項

- TRANSACTION の論理削除フラグ（既存DWHでは未保持）の取り扱いは未確定。PoC 中に業務側と合意する。
- 既存DWH の `MART.*` 集計ビューを Silver でも保持するか、Gold だけに集約するかは PoC で判断する。
