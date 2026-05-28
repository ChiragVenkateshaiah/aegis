# Day 02 — Ontology Gap Observations

**Status:** Parked — no action taken. Bring to a future iteration chunk (Phase 1 closeout or Phase 2 kickoff).
**Date:** 2026-05-21
**Reconstructed:** 2026-05-28

These 7 observations emerged from comparing the OCC credit-memo section breakdown against the Day 1 ontology (`data/schemas/ontology.sql`). None are blockers for Phase 1. All are candidates for a schema v2 ADR before Phase 3.

---

## GAP-01 — Single risk_rating field cannot model dual risk rating

**What the OCC requires:** Two separate grades — BRR (Borrower Risk Rating, PD proxy) and FRR (Facility Risk Rating, LGD proxy). They move independently: a borrower's BRR can deteriorate while a well-secured facility's FRR stays stable.

**Current ontology state:** The `loans` or `credit_applications` table carries a single `risk_rating` field.

**Impact:** Phase 3 risk-rating logic (T3 prompt engineering) will produce structurally wrong output if the schema only has one slot. The LLM will need two separate output fields to be mapped correctly.

**Proposed fix:** Split into `borrower_risk_rating` (INT, 1–10) and `facility_risk_rating` (INT, 1–10), each with a corresponding `_rationale` TEXT column.

---

## GAP-02 — No covenant table

**What the OCC requires:** The covenant package is a first-class credit memo section. Covenants have type (financial/reporting/affirmative/negative), metric name, threshold, test frequency, and compliance status.

**Current ontology state:** No `covenants` table; covenant terms are not modeled.

**Impact:** The Phase 4 credit memo generator cannot emit a properly structured covenant section. Covenant compliance tracking (a stretch Phase 5 feature) also has no substrate.

**Proposed fix:** Add `covenants(id, loan_id, covenant_type, metric_name, threshold_value, threshold_operator, test_frequency, compliance_status, last_tested_date)`.

---

## GAP-03 — Collateral table missing advance_rate and liquidation value fields

**What the OCC requires:** Each collateral item needs: appraised value, advance rate (%), orderly liquidation value (OLV), forced liquidation value (FLV), appraisal date, and appraisal firm.

**Current ontology state:** `collateral` table likely has value and type but not the full valuation breakdown.

**Impact:** Collateral coverage calculations in the credit memo (`collateral_value × advance_rate / loan_amount`) cannot be computed correctly.

**Proposed fix:** Add `advance_rate NUMERIC(5,4)`, `olv NUMERIC(18,2)`, `flv NUMERIC(18,2)`, `appraisal_date DATE`, `appraisal_firm TEXT` to the `collateral` table.

---

## GAP-04 — No guarantor entity

**What the OCC requires:** Personal guarantors are a distinct entity type from the borrowing business. Each guarantor has: personal net worth, liquid assets, personal income (from personal tax return K-1/Schedule C), personal debt obligations, and personal credit score.

**Current ontology state:** No `guarantors` table; guarantors not modeled separately from owners.

**Impact:** Global DSCR calculation requires guarantor personal income and obligations — these cannot be derived if guarantors aren't a first-class entity.

**Proposed fix:** Add `guarantors(id, borrower_id, full_name, personal_net_worth, liquid_assets, annual_personal_income, annual_personal_debt_service, credit_score)` with provenance columns.

---

## GAP-05 — No UCA cash flow structure

**What the OCC requires:** UCA cash flow has a specific four-level waterfall (Cash After Operations, Cash After Debt Service, Cash After Distributions, Net Cash Position). It is not equivalent to net income or EBITDA.

**Current ontology state:** The `financial_statements` or similar table likely stores line items but not the UCA-specific reclassification buckets.

**Impact:** The extraction pipeline (Phase 2) will extract raw P&L line items; without a UCA reclassification layer, the Phase 3 DSCR calculation will use the wrong cash flow basis.

**Proposed fix:** Add a `uca_cash_flow(id, financial_statement_id, cash_after_operations, cash_after_debt_service, cash_after_distributions, net_cash_position, period_end_date)` table. The reclassification logic lives in the extraction/ratios layer, not the schema.

---

## GAP-06 — Sources and uses not modeled

**What the OCC requires:** The sources-and-uses table (Section 2 of the credit memo) must balance: total sources = total uses. This is a distinct data structure from the loan amount field.

**Current ontology state:** Loan amount and purpose are captured, but the structured sources/uses breakdown is not.

**Impact:** The credit memo generator cannot emit a Section 2 table. Also, sources/uses imbalance is a quality-check signal the system could flag automatically.

**Proposed fix:** Add `loan_sources(id, loan_id, source_type, amount)` and `loan_uses(id, loan_id, use_type, amount)`. Add a check constraint or trigger that validates `SUM(sources) = SUM(uses)` at memo-finalization time.

---

## GAP-07 — No industry benchmark reference

**What the OCC requires:** The financial analysis section benchmarks the borrower's ratios against industry peers (typically RMA Annual Statement Studies data). Without a benchmark, the memo is qualitatively weaker and cannot flag outlier ratios.

**Current ontology state:** Ratio values are stored but with no reference to peer benchmarks.

**Impact:** Phase 3 ratio analysis prompts will produce narrative without "above/below industry median" context unless a benchmark table exists.

**Proposed fix:** Add `industry_benchmarks(naics_code, metric_name, p25, p50, p75, source, as_of_year)`. Populate with FFIEC or public proxy data given RMA is subscription-only (see source-log). Flag as a known data gap.

---

## Next steps (parked)

- Review all 7 gaps against the Phase 1 closeout milestone before tagging `phase-1-complete`.
- Decide which gaps warrant a v2 schema DDL iteration (likely GAP-01, GAP-04) vs. which are Phase 2+ concerns (GAP-05, GAP-06, GAP-07).
- Open ADR for any schema changes adopted.
