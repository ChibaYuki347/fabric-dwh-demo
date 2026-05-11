# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   }
# META }

# MARKDOWN ********************

# # 02 — Validate Warehouse load
# 
# Runs the four reconciliation checks defined under `tests/` against the
# `DWH_Modernization_Demo` Warehouse, after `01_load_warehouse` has finished.
# 
# Checks performed:
# 
# 1. **Row count** — every table reports a non-zero count and matches the source CSV count.
# 2. **Key uniqueness** — no duplicate keys for primary identifiers.
# 3. **NULL rate** — `RiskScore`, `RegionCode`, `ChannelCode`, `StatusCode` stay under thresholds.
# 4. **Aggregate** — `dbo.vw_BranchBalance` sums match per-branch totals from `dbo.[Transaction]`.

# METADATA ********************

# META {
# META   "language": "markdown",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

WAREHOUSE = "DWH_Modernization_Demo"

# Expected row counts come from the synthetic CSV row counts (see inventory/sample_data/README.md).
EXPECTED = {
    "Customer": 25,
    "Account": 40,
    "Branch": 8,
    "Transaction": 80,
}

# NULL-rate thresholds mirror tests/sample_test_results.md.
NULL_THRESHOLDS = {
    ("Customer", "RiskScore"): 0.02,
    ("Customer", "CustomerSegment"): 0.05,
    ("Account", "StatusCode"): 0.01,
    ("Transaction", "ChannelCode"): 0.05,
}

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 1. Row counts

# METADATA ********************

# META {
# META   "language": "markdown",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

rows = []
for tbl, expected in EXPECTED.items():
    name = "[Transaction]" if tbl == "Transaction" else tbl
    df = spark.read.synapsesql(f"{WAREHOUSE}.dbo.{name}")
    actual = df.count()
    status = "PASS" if actual == expected else "FAIL"
    rows.append((tbl, expected, actual, status))

display(spark.createDataFrame(rows, ["Table", "Expected", "Actual", "Status"]))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 2. Key uniqueness

# METADATA ********************

# META {
# META   "language": "markdown",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import count as F_count

key_pairs = [
    ("Customer", "CustomerId"),
    ("Account", "AccountId"),
    ("Branch", "BranchId"),
    ("Transaction", "TransactionId"),
]

rows = []
for tbl, key in key_pairs:
    name = "[Transaction]" if tbl == "Transaction" else tbl
    df = spark.read.synapsesql(f"{WAREHOUSE}.dbo.{name}")
    dup = df.groupBy(key).agg(F_count("*").alias("n")).filter("n > 1").count()
    rows.append((tbl, key, dup, "PASS" if dup == 0 else "FAIL"))

display(spark.createDataFrame(rows, ["Table", "Key", "DuplicateKeyGroups", "Status"]))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 3. NULL rate

# METADATA ********************

# META {
# META   "language": "markdown",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col

rows = []
for (tbl, column), threshold in NULL_THRESHOLDS.items():
    name = "[Transaction]" if tbl == "Transaction" else tbl
    df = spark.read.synapsesql(f"{WAREHOUSE}.dbo.{name}")
    total = df.count()
    nulls = df.filter(col(column).isNull()).count()
    rate = (nulls / total) if total else 0.0
    status = "PASS" if rate <= threshold else "FAIL"
    rows.append((tbl, column, total, nulls, round(rate, 4), threshold, status))

display(spark.createDataFrame(
    rows,
    ["Table", "Column", "Total", "Nulls", "Rate", "Threshold", "Status"],
))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## 4. Aggregate reconciliation
# 
# Compare `dbo.vw_BranchBalance` (curated) against a fresh aggregation of
# `dbo.Account JOIN dbo.[Transaction]`. They must match per `(BranchId, TransactionDate)`.

# METADATA ********************

# META {
# META   "language": "markdown",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import sum as F_sum, count as F_count, lit

view = spark.read.synapsesql(f"{WAREHOUSE}.dbo.vw_BranchBalance")
acct = spark.read.synapsesql(f"{WAREHOUSE}.dbo.Account")
txn = spark.read.synapsesql(f"{WAREHOUSE}.dbo.[Transaction]")

derived = (
    acct.alias("a")
    .join(txn.alias("t"), "AccountId")
    .groupBy("BranchId", "TransactionDate")
    .agg(
        F_sum("Amount").alias("DailyAmount_derived"),
        F_count(lit(1)).alias("TransactionCount_derived"),
    )
)

joined = view.join(derived, ["BranchId", "TransactionDate"], "outer")
mismatches = joined.filter(
    (joined.DailyAmount != joined.DailyAmount_derived)
    | (joined.TransactionCount != joined.TransactionCount_derived)
).count()

print(f"vw_BranchBalance rows:           {view.count()}")
print(f"derived aggregation rows:        {derived.count()}")
print(f"mismatched (BranchId, Date) keys: {mismatches}  (expect 0)")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
