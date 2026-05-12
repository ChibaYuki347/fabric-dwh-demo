# Fabric notebook source


# MARKDOWN ********************

# # 00 — Seed Lakehouse with synthetic CSVs
# 
# Downloads the synthetic CSVs from the public **fabric-dwh-demo** GitHub repo
# into the default lakehouse `RawZone` at `Files/raw/<table>.csv`.
# 
# **Prerequisites**
# 1. Attach this notebook to the **RawZone** lakehouse via the *Add lakehouse* panel on the left.
# 2. Internet access is required (public GitHub raw URL).
# 
# This notebook is **idempotent**: re-runs overwrite the destination files.

# CELL ********************

import os
import urllib.request

GITHUB_OWNER = "ChibaYuki347"
GITHUB_REPO = "fabric-dwh-demo"
GITHUB_BRANCH = "main"
TABLES = ["customer", "account", "branch", "transaction"]

TARGET_DIR = "/lakehouse/default/Files/raw"
os.makedirs(TARGET_DIR, exist_ok=True)

for name in TABLES:
    url = (
        f"https://raw.githubusercontent.com/{GITHUB_OWNER}/{GITHUB_REPO}/"
        f"{GITHUB_BRANCH}/inventory/sample_data/{name}.csv"
    )
    dest = f"{TARGET_DIR}/{name}.csv"
    urllib.request.urlretrieve(url, dest)
    size = os.path.getsize(dest)
    print(f"  {name:<12} {size:>6} bytes  <- {url}")

print("\nSeed complete.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Verify

# CELL ********************

import subprocess
print(subprocess.check_output(["ls", "-la", TARGET_DIR]).decode())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
