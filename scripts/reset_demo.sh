#!/usr/bin/env bash
# Reset the Fabric Warehouse to a clean state before a rehearsal or live demo.
#
# What it does
# ------------
# 1. TRUNCATE every Warehouse table so 01_load_warehouse starts from zero.
# 2. (Optional) Re-apply post-deployment security objects.
#
# What it does NOT do
# -------------------
# * Re-create the Warehouse itself — that is owned by Fabric Git integration and
#   refreshed via Workspace -> Source control -> Update from Git.
# * Touch the Lakehouse Files. 00_seed_lakehouse handles seeding.
#
# Prerequisites
# -------------
# * Microsoft ODBC Driver 18 for SQL Server is installed (sqlcmd is included).
# * The .env file has been populated from .env.example.
# * You are signed in with `az login` (we use Entra ID interactive auth).
#
# Usage
# -----
#   ./scripts/reset_demo.sh            # TRUNCATE only
#   ./scripts/reset_demo.sh --security # also re-apply post-deployment/security.sql

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  # shellcheck disable=SC1091
  source "${REPO_ROOT}/.env"
else
  echo "ERROR: ${REPO_ROOT}/.env not found. Copy .env.example and fill in values." >&2
  exit 1
fi

: "${SQL_ENDPOINT:?SQL_ENDPOINT must be set in .env}"
: "${WAREHOUSE_NAME:?WAREHOUSE_NAME must be set in .env}"

APPLY_SECURITY=0
for arg in "$@"; do
  case "${arg}" in
    --security) APPLY_SECURITY=1 ;;
    *) echo "Unknown argument: ${arg}" >&2; exit 2 ;;
  esac
done

if ! command -v sqlcmd >/dev/null 2>&1; then
  echo "ERROR: sqlcmd not found. Install Microsoft ODBC Driver 18 for SQL Server." >&2
  exit 1
fi

TABLES=(Customer Account Branch DailyBalance "[Transaction]")

echo "Resetting warehouse: ${WAREHOUSE_NAME} on ${SQL_ENDPOINT}"
for tbl in "${TABLES[@]}"; do
  echo "  TRUNCATE dbo.${tbl}"
  sqlcmd \
    -S "${SQL_ENDPOINT}" \
    -d "${WAREHOUSE_NAME}" \
    --authentication-method ActiveDirectoryInteractive \
    -Q "TRUNCATE TABLE dbo.${tbl};"
done

if [[ "${APPLY_SECURITY}" == "1" ]]; then
  echo "Re-applying post-deployment/security.sql"
  sqlcmd \
    -S "${SQL_ENDPOINT}" \
    -d "${WAREHOUSE_NAME}" \
    --authentication-method ActiveDirectoryInteractive \
    -i "${REPO_ROOT}/fabric/post-deployment/security.sql"
fi

echo "Reset complete."
