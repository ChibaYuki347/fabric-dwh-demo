# Fabric notebook source


# MARKDOWN ********************

# # 01 — Load Warehouse from Lakehouse CSVs
# 
# Reads CSVs from the attached lakehouse (`RawZone.Files/raw/`), casts them to the
# Warehouse column types declared in
# `fabric/DWH_Modernization_Demo.Warehouse/Schemas/dbo/Tables/`,
# and appends them into `DWH_Modernization_Demo.dbo.<Table>` via the
# Spark `synapsesql` connector.
# 
# **Prerequisites**
# 1. `RawZone` lakehouse attached.
# 2. `00_seed_lakehouse` notebook has been executed (Files/raw populated).
# 3. `DWH_Modernization_Demo` Warehouse has been created via *Workspace settings -> Source control -> Update from Git*.
# 4. The four tables are empty. If a previous demo loaded data, run `scripts/reset_demo.sh` first.

# CELL ********************

WAREHOUSE = "DWH_Modernization_Demo"
LAKEHOUSE_RAW = "Files/raw"
print(f"Target warehouse: {WAREHOUSE}")
print(f"Source path:      {LAKEHOUSE_RAW}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Customer

# CELL ********************

from pyspark.sql.functions import col, to_date, to_timestamp

df = (
    spark.read.option("header", "true").csv(f"{LAKEHOUSE_RAW}/customer.csv")
    .select(
        col("CUSTOMER_ID").cast("int").alias("CustomerId"),
        col("CUSTOMER_SEGMENT").alias("CustomerSegment"),
        to_date(col("OPEN_DATE")).alias("OpenDate"),
        col("RISK_SCORE").cast("decimal(5,2)").alias("RiskScore"),
        to_timestamp(col("UPDATED_AT")).alias("UpdatedAt"),
    )
)
df.show(5, truncate=False)
df.write.mode("append").synapsesql(f"{WAREHOUSE}.dbo.Customer")
print(f"loaded {df.count()} rows into dbo.Customer")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Branch

# CELL ********************

from pyspark.sql.functions import col, to_date, to_timestamp

df = (
    spark.read.option("header", "true").csv(f"{LAKEHOUSE_RAW}/branch.csv")
    .select(
        col("BRANCH_ID").cast("int").alias("BranchId"),
        col("BRANCH_NAME").alias("BranchName"),
        col("REGION_CD").alias("RegionCode"),
        to_date(col("OPEN_DATE")).alias("OpenDate"),
        col("STATUS_CD").alias("StatusCode"),
        to_timestamp(col("UPDATED_AT")).alias("UpdatedAt"),
    )
)
df.write.mode("append").synapsesql(f"{WAREHOUSE}.dbo.Branch")
print(f"loaded {df.count()} rows into dbo.Branch")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Account

# CELL ********************

from pyspark.sql.functions import col, to_date, to_timestamp

df = (
    spark.read.option("header", "true").csv(f"{LAKEHOUSE_RAW}/account.csv")
    .select(
        col("ACCOUNT_ID").cast("long").alias("AccountId"),
        col("CUSTOMER_ID").cast("int").alias("CustomerId"),
        col("BRANCH_ID").cast("int").alias("BranchId"),
        col("ACCOUNT_TYPE").alias("AccountType"),
        col("STATUS_CD").alias("StatusCode"),
        to_date(col("OPEN_DATE")).alias("OpenDate"),
        to_timestamp(col("UPDATED_AT")).alias("UpdatedAt"),
    )
)
df.write.mode("append").synapsesql(f"{WAREHOUSE}.dbo.Account")
print(f"loaded {df.count()} rows into dbo.Account")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Transaction
# 
# `Transaction` is a T-SQL reserved word, so we quote it as `dbo.[Transaction]`.

# CELL ********************

from pyspark.sql.functions import col, to_date, to_timestamp

df = (
    spark.read.option("header", "true").csv(f"{LAKEHOUSE_RAW}/transaction.csv")
    .select(
        col("TRANSACTION_ID").cast("long").alias("TransactionId"),
        col("ACCOUNT_ID").cast("long").alias("AccountId"),
        to_date(col("TRANSACTION_DATE")).alias("TransactionDate"),
        col("AMOUNT").cast("decimal(18,2)").alias("Amount"),
        col("CHANNEL_CD").alias("ChannelCode"),
        to_timestamp(col("UPDATED_AT")).alias("UpdatedAt"),
    )
)
df.write.mode("append").synapsesql(f"{WAREHOUSE}.dbo.[Transaction]")
print(f"loaded {df.count()} rows into dbo.[Transaction]")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

print("All loads complete. Run `02_validate` next.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
