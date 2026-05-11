---
applyTo:
  - "api/**"
---

# API Instructions

APIs expose curated Fabric outputs, never raw operational tables.

1. Define the OpenAPI contract in `api/openapi.yaml` first; implementation in `api/src/` must match it.
2. Source only from Fabric Warehouse curated objects: `dbo.vw_BranchBalance`, `dbo.DailyBalance`. Do not query `dbo.[Transaction]` directly from the API tier.
3. Keep payloads minimal. Only return fields the consumer needs.
4. Document authorization assumptions and rate limits in code comments. The demo stub does not implement auth; production must use Entra ID / OAuth2.
5. Validate inputs. Reject requests without `businessDate`; treat `branchId` as optional.
6. Provide pytest coverage in `api/tests/` for at least: missing required parameter, valid happy path, optional parameter behavior.
7. Never log raw request bodies or response payloads that could contain customer identifiers. The demo stub returns only synthetic numerics.
