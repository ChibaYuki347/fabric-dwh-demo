## Purpose

Describe the DWH object, pipeline, or API change included in this migration PR. Keep it short enough that an executive can read it in 60 seconds.

## Migration Scope

- Source objects:
- Fabric target objects:
- Data volume / refresh pattern:
- Affected pipelines:
- Affected APIs / Power BI semantic models:

## Copilot-Assisted Work

Document which parts were drafted or reviewed using GitHub Copilot, and what human validation was performed. Reference `docs/copilot_prompt_cards.md` if a standard prompt was used.

- Prompts used:
- Files Copilot drafted:
- Files Copilot reviewed:
- Human validation performed:

## Validation Evidence

- [ ] SQL build check passed (`.github/workflows/sql-build.yml`)
- [ ] Row count reconciliation completed (`tests/row_count_reconciliation.sql`)
- [ ] Aggregate reconciliation completed (`tests/aggregate_reconciliation.sql`)
- [ ] Key uniqueness check completed (`tests/key_uniqueness_check.sql`)
- [ ] NULL rate check completed (`tests/null_rate_check.sql`)
- [ ] Security scan passed (`.github/workflows/security-scan.yml`)
- [ ] Sample test results updated (`tests/sample_test_results.md`) when thresholds or new tests were introduced

## SQL Dialect Notes

List any conversion decisions that deviate from `docs/sql_dialect_mapping.md` and explain why.

## Risks and Rollback

- Migration risks:
- Rollback steps:
- Blast radius if rollback is delayed:

## Out of Scope

State explicitly what this PR does **not** address so reviewers do not block on unrelated items.
