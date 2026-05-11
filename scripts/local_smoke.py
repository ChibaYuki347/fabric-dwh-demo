"""Local smoke test using DuckDB as a stand-in for the Fabric Warehouse.

Why
---
The live demo depends on the Fabric Trial Capacity and an internet connection.
This script lets the presenter rehearse the *data* portion of the demo entirely
offline. It mirrors the four reconciliation checks performed by
`fabric/02_validate.Notebook/notebook-content.py`.

What it does
------------
1. Creates an in-memory DuckDB database.
2. Loads CSVs from `inventory/sample_data/` into tables that mimic the Fabric
   Warehouse schema (with T-SQL types translated to DuckDB equivalents).
3. Runs the four checks (row count, key uniqueness, NULL rate, aggregate).
4. Exits with code 0 if all checks pass, 1 otherwise.

T-SQL -> DuckDB translation table
---------------------------------
| T-SQL                | DuckDB        |
|----------------------|---------------|
| DATETIME2(6)         | TIMESTAMP     |
| DECIMAL(p, s)        | DECIMAL(p, s) |
| VARCHAR(n) / CHAR(n) | VARCHAR       |
| BIGINT / INT         | BIGINT / INT  |
| dbo.[Transaction]    | "Transaction" |

Run
---
    python -m pip install -r scripts/requirements-dev.txt
    python scripts/local_smoke.py
"""

from __future__ import annotations

import sys
from pathlib import Path

import duckdb

REPO_ROOT = Path(__file__).resolve().parents[1]
CSV_DIR = REPO_ROOT / "inventory" / "sample_data"

EXPECTED_ROWS = {
    "Customer": 25,
    "Account": 40,
    "Branch": 8,
    "Transaction": 80,
}

NULL_THRESHOLDS = {
    ("Customer", "RiskScore"): 0.02,
    ("Customer", "CustomerSegment"): 0.05,
    ("Account", "StatusCode"): 0.01,
    ("Transaction", "ChannelCode"): 0.05,
}


def _create_schema(con: duckdb.DuckDBPyConnection) -> None:
    con.execute(
        """
        CREATE TABLE Customer (
            CustomerId INT NOT NULL,
            CustomerSegment VARCHAR,
            OpenDate DATE,
            RiskScore DECIMAL(5,2),
            UpdatedAt TIMESTAMP
        );
        CREATE TABLE Account (
            AccountId BIGINT NOT NULL,
            CustomerId INT NOT NULL,
            BranchId INT NOT NULL,
            AccountType VARCHAR,
            StatusCode VARCHAR,
            OpenDate DATE,
            UpdatedAt TIMESTAMP
        );
        CREATE TABLE Branch (
            BranchId INT NOT NULL,
            BranchName VARCHAR NOT NULL,
            RegionCode VARCHAR,
            OpenDate DATE,
            StatusCode VARCHAR,
            UpdatedAt TIMESTAMP
        );
        CREATE TABLE "Transaction" (
            TransactionId BIGINT NOT NULL,
            AccountId BIGINT NOT NULL,
            TransactionDate DATE NOT NULL,
            Amount DECIMAL(18,2) NOT NULL,
            ChannelCode VARCHAR,
            UpdatedAt TIMESTAMP
        );
        """
    )


def _load_csvs(con: duckdb.DuckDBPyConnection) -> None:
    con.execute(
        f"""
        INSERT INTO Customer
        SELECT
            CUSTOMER_ID::INT,
            CUSTOMER_SEGMENT,
            OPEN_DATE::DATE,
            RISK_SCORE::DECIMAL(5,2),
            UPDATED_AT::TIMESTAMP
        FROM read_csv_auto('{CSV_DIR / "customer.csv"}', header=true);

        INSERT INTO Account
        SELECT
            ACCOUNT_ID::BIGINT,
            CUSTOMER_ID::INT,
            BRANCH_ID::INT,
            ACCOUNT_TYPE,
            STATUS_CD,
            OPEN_DATE::DATE,
            UPDATED_AT::TIMESTAMP
        FROM read_csv_auto('{CSV_DIR / "account.csv"}', header=true);

        INSERT INTO Branch
        SELECT
            BRANCH_ID::INT,
            BRANCH_NAME,
            REGION_CD,
            OPEN_DATE::DATE,
            STATUS_CD,
            UPDATED_AT::TIMESTAMP
        FROM read_csv_auto('{CSV_DIR / "branch.csv"}', header=true);

        INSERT INTO "Transaction"
        SELECT
            TRANSACTION_ID::BIGINT,
            ACCOUNT_ID::BIGINT,
            TRANSACTION_DATE::DATE,
            AMOUNT::DECIMAL(18,2),
            CHANNEL_CD,
            UPDATED_AT::TIMESTAMP
        FROM read_csv_auto('{CSV_DIR / "transaction.csv"}', header=true);
        """
    )


def _check_row_counts(con: duckdb.DuckDBPyConnection) -> list[str]:
    failures: list[str] = []
    for tbl, expected in EXPECTED_ROWS.items():
        ident = '"Transaction"' if tbl == "Transaction" else tbl
        actual = con.execute(f"SELECT COUNT(*) FROM {ident}").fetchone()[0]
        status = "PASS" if actual == expected else "FAIL"
        print(f"  rowcount   {tbl:<13} expected={expected:<3} actual={actual:<3} {status}")
        if status == "FAIL":
            failures.append(f"{tbl}: expected {expected}, got {actual}")
    return failures


def _check_uniqueness(con: duckdb.DuckDBPyConnection) -> list[str]:
    failures: list[str] = []
    for tbl, key in [
        ("Customer", "CustomerId"),
        ("Account", "AccountId"),
        ("Branch", "BranchId"),
        ("Transaction", "TransactionId"),
    ]:
        ident = '"Transaction"' if tbl == "Transaction" else tbl
        dup = con.execute(
            f"SELECT COUNT(*) FROM (SELECT {key} FROM {ident} GROUP BY {key} HAVING COUNT(*) > 1)"
        ).fetchone()[0]
        status = "PASS" if dup == 0 else "FAIL"
        print(f"  uniqueness {tbl:<13} key={key:<14} duplicates={dup} {status}")
        if status == "FAIL":
            failures.append(f"{tbl}.{key}: {dup} duplicate key group(s)")
    return failures


def _check_nulls(con: duckdb.DuckDBPyConnection) -> list[str]:
    failures: list[str] = []
    for (tbl, col), threshold in NULL_THRESHOLDS.items():
        ident = '"Transaction"' if tbl == "Transaction" else tbl
        total, nulls = con.execute(
            f"SELECT COUNT(*), COUNT(*) FILTER (WHERE {col} IS NULL) FROM {ident}"
        ).fetchone()
        rate = (nulls / total) if total else 0.0
        status = "PASS" if rate <= threshold else "FAIL"
        print(
            f"  null-rate  {tbl:<13} col={col:<16} rate={rate:.4f} <= {threshold} {status}"
        )
        if status == "FAIL":
            failures.append(f"{tbl}.{col}: NULL rate {rate:.4f} > {threshold}")
    return failures


def _check_aggregate(con: duckdb.DuckDBPyConnection) -> list[str]:
    failures: list[str] = []
    mismatches = con.execute(
        """
        WITH derived AS (
            SELECT a.BranchId,
                   t.TransactionDate,
                   SUM(t.Amount)  AS DailyAmount,
                   COUNT(*)       AS TransactionCount
            FROM Account a
            JOIN "Transaction" t ON a.AccountId = t.AccountId
            GROUP BY a.BranchId, t.TransactionDate
        )
        SELECT COUNT(*)
        FROM derived
        WHERE NOT EXISTS (
            SELECT 1 FROM derived d2
            WHERE d2.BranchId = derived.BranchId
              AND d2.TransactionDate = derived.TransactionDate
        );
        """
    ).fetchone()[0]
    status = "PASS" if mismatches == 0 else "FAIL"
    print(f"  aggregate  vw_BranchBalance derivable: mismatches={mismatches} {status}")
    if status == "FAIL":
        failures.append(f"vw_BranchBalance derivation: {mismatches} mismatches")
    return failures


def main() -> int:
    print("DuckDB smoke test for the Fabric Warehouse schema\n")
    con = duckdb.connect(":memory:")
    _create_schema(con)
    _load_csvs(con)

    failures: list[str] = []
    failures += _check_row_counts(con)
    failures += _check_uniqueness(con)
    failures += _check_nulls(con)
    failures += _check_aggregate(con)

    print()
    if failures:
        print(f"FAILED ({len(failures)}):")
        for f in failures:
            print(f"  - {f}")
        return 1

    print("All checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
