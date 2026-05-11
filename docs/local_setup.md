# ローカル開発・デモ実行環境のセットアップ

このリポジトリの **ライブデモ** をプレゼンタ自身の PC で動かすための環境構築手順です。
顧客環境への展開手順ではなく、**プレゼンタの手元** を想定しています。

> 顧客にライブデモを見せるのが目的なので、最低限のツールが揃えば十分です。
> 全部入りを目指す必要はありません。

---

## 1. 必要なソフトウェア

| ツール | 用途 | インストール |
|---|---|---|
| **VS Code** | エディタ | <https://code.visualstudio.com/> |
| **GitHub Copilot** + **Copilot Chat** 拡張 | コード生成・PR レビュー | VS Code Marketplace |
| **Git** | バージョン管理 | OS パッケージマネージャ |
| **GitHub CLI (`gh`)** | PR 作成 | <https://cli.github.com/> |
| **Python 3.11+** | ローカル smoke / pytest | <https://www.python.org/> |
| **Microsoft ODBC Driver 18 for SQL Server** | `sqlcmd` 経由で Fabric Warehouse へ接続 | <https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server> |
| **Azure CLI (`az`)** | Entra ID 認証 (`az login`) | <https://learn.microsoft.com/cli/azure/install-azure-cli> |

任意:

- **Microsoft Fabric CLI (`fabric-cli`)** — 試験段階。`pip install ms-fabric-cli`。
- **uv / pipx** — Python パッケージ管理を高速化したい場合。

---

## 2. リポジトリのクローン

```bash
gh repo clone ChibaYuki347/fabric-dwh-demo
cd fabric-dwh-demo
```

---

## 3. Python 依存をインストール

```bash
python -m venv .venv
source .venv/bin/activate            # Windows なら .venv\Scripts\activate
python -m pip install -r scripts/requirements-dev.txt
```

---

## 4. `.env` を用意

`.env.example` をコピーして実値を埋めます。

```bash
cp .env.example .env
```

| キー | どこで確認 |
|---|---|
| `TENANT_ID` | Azure portal -> Microsoft Entra ID -> Overview |
| `WORKSPACE_ID` | Fabric ポータルで Workspace を開いた URL の GUID |
| `WAREHOUSE_NAME` | 既定値 `DWH_Modernization_Demo`（このデモではそのまま） |
| `LAKEHOUSE_NAME` | 既定値 `RawZone`（このデモではそのまま） |
| `SQL_ENDPOINT` | Workspace -> Warehouse -> Settings -> SQL connection string |
| `SP_CLIENT_ID` / `SP_CLIENT_SECRET` | ライブデモでは未使用。自動化したい場合のみ |

> `.env` は `.gitignore` 済みなので、本物の値を入れても commit されません。

---

## 5. オフライン smoke 実行

ネット不調や Fabric 障害でも、データ周りのデモは DuckDB で代替できます。

```bash
python scripts/local_smoke.py
```

期待される出力:

```
All checks passed.
```

これが緑のうちは、CSV と SQL スキーマの整合は取れています。

---

## 6. pytest（CI 同等のローカルチェック）

```bash
pytest -q
```

---

## 7. Fabric Workspace への接続確認

`az login` 後、Warehouse の TRUNCATE を試して接続を確認します。

```bash
az login
./scripts/reset_demo.sh
```

`Reset complete.` が出れば、SQL_ENDPOINT・認証ともに OK です。

---

## 8. 「リハーサル可」のチェックリスト

- [ ] `python scripts/local_smoke.py` が緑
- [ ] `pytest -q` が緑
- [ ] `./scripts/reset_demo.sh` が成功する
- [ ] Fabric ポータルで Workspace のタブが開ける
- [ ] Workspace -> Source control に `ChibaYuki347/fabric-dwh-demo` が接続済み

ここまで揃えば、ライブデモを通しで実施できます。
