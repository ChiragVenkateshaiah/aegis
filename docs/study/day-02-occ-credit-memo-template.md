# Day 02 — OCC Credit-Memo Template: Section-by-Section Breakdown

**Source:** OCC Comptroller's Handbook — Commercial Loans (and Rating Credit Risk supplement)
**Date studied:** 2026-05-21
**Reconstructed:** 2026-05-28 (original lost; content rebuilt from domain knowledge)

---

## Overview

A commercial credit memo is the primary underwriting document a lender produces to justify a credit decision. The OCC Comptroller's Handbook defines the minimum analytical elements an examiner expects to see. The 14 sections below reflect the canonical OCC structure for an SME commercial term loan or revolving line.

---

## Section 1 — Credit Request Summary

**What it contains:**
Borrower legal name, TIN, NAICS code, loan amount requested, loan type (term / revolver / LOC), requested rate and structure, purpose of proceeds, collateral summary, and recommended risk rating (BRR + FRR).

**Why it matters:**
This is the executive one-pager. A credit committee member who reads nothing else reads this. Every number here must reconcile exactly to the body of the memo — discrepancies are an examiner red flag.

**Evidence sources:**
Loan application, borrower authorization form, existing relationship summary if renewal.

---

## Section 2 — Purpose of Credit and Sources/Uses

**What it contains:**
A narrative description of why the borrower needs the money and a table showing total sources of funds (equity injection, senior debt, seller financing) vs. total uses (equipment purchase, working capital, refinance payoff, closing costs). Sources must equal uses to the dollar.

**Why it matters:**
Mismatched sources/uses is a common underwriting deficiency cited in OCC examination findings. It also establishes whether the loan is for productive investment (good) vs. plugging operating losses (warning signal).

**Evidence sources:**
Borrower letter of explanation, purchase agreement (if acquisition), payoff statement (if refinance).

---

## Section 3 — Borrower Background and Business Description

**What it contains:**
Legal entity type, state of formation, years in business, ownership structure (percentage table), primary business activity, key customers / suppliers, seasonality, geographic market, and a brief competitive positioning statement.

**Why it matters:**
Establishes whether the examiner is looking at a viable going concern. Management depth and ownership concentration are underwriting risk factors — a sole-owner business where the owner is also the key employee and sole guarantor concentrates risk in one person.

**Evidence sources:**
Articles of incorporation, operating agreement, business license, CPA-prepared organizational chart.

---

## Section 4 — Management Assessment

**What it contains:**
Named principals, years of industry experience, prior credit history with the institution, relevant education/credentials, succession plan (or notation that none exists), and any adverse background check findings.

**Why it matters:**
OCC guidance identifies management quality as the single most important non-financial factor. A business with weak financials but strong management is a better risk than the reverse. Management assessment also anchors the BRR qualitative component.

**Evidence sources:**
Personal financial statements, background check results, LinkedIn/industry reference check notes, prior exam reports if renewal.

---

## Section 5 — Industry and Market Analysis

**What it contains:**
NAICS industry description, market size and growth trend, key competitive dynamics, regulatory environment, macroeconomic sensitivity (cyclicality, interest-rate sensitivity), and a brief Porter-style positioning of the borrower within its market.

**Why it matters:**
Industry outlook feeds directly into the BRR qualitative scoring. An otherwise strong borrower in a deteriorating industry (e.g., commercial printing, brick-and-mortar retail) warrants a higher PD than one in a growing sector.

**Evidence sources:**
IBISWorld or RMA Annual Statement Studies industry data, FDIC call report sector data, trade association publications.

---

## Section 6 — Historical Financial Analysis

**What it contains:**
Three years of spreading: income statement (revenue, COGS, gross profit, SG&A, EBITDA, net income), balance sheet (current assets, fixed assets, total assets, current liabilities, long-term debt, equity), and a ratio table (current ratio, quick ratio, gross margin, net margin, leverage, tangible net worth).

**Why it matters:**
The spread is the quantitative backbone of the underwriting. Examiners look for trend deterioration, aggressive revenue recognition, unexplained asset growth, and leverage trends. Spreading must use the borrower's own fiscal year, not a calendar-year normalization, unless a CPA attestation covers the normalization.

**Evidence sources:**
Business tax returns (Form 1120 / 1120-S / 1065) — 3 years; CPA-compiled or reviewed financials preferred; internally-prepared financials acceptable for smaller loans with a note in the file.

---

## Section 7 — Cash Flow Analysis (UCA Method)

**What it contains:**
The Uniform Credit Analysis (UCA) cash flow statement, which reclassifies accounting income into four buckets: (1) Cash After Operations, (2) Cash After Debt Service, (3) Cash After Dividends/Distributions, and (4) Net Cash Position. The analysis projects the current period and at least one forward period.

**Why it matters:**
UCA cash flow is the OCC-preferred method because it starts from actual cash receipts rather than accrual net income, making it harder for a borrower to obscure negative operating cash flow with timing games. The DSCR computed from UCA cash flow is the primary sizing constraint for term debt.

**Evidence sources:**
Same financials as Section 6, re-cast using UCA methodology. The analyst's working spreadsheet is a required file document.

**Key metrics derived:**
- Cash After Operations (CAO)
- Debt Service Coverage Ratio: CAO ÷ (annual P&I)
- Global DSCR: (CAO + guarantor personal income) ÷ (business debt service + personal debt obligations)

---

## Section 8 — Balance Sheet and Collateral Quality Analysis

**What it contains:**
Asset-by-asset quality review: accounts receivable aging (% current, % 30/60/90+ days), inventory obsolescence risk, fixed asset condition and appraisal status, intangibles/goodwill write-down risk, and off-balance-sheet exposures (operating leases, contingent liabilities, related-party loans).

**Why it matters:**
The OCC distinguishes between "book" asset values and "bankable" asset values. A borrower's balance sheet may show $500K in receivables but if 40% are 90+ days, the bankable AR is closer to $300K — which changes the borrowing base calculation on a revolving line.

**Evidence sources:**
AR aging report (from borrower's accounting system), inventory listing with age and condition notes, real estate appraisal (FIRREA-compliant for CRE), equipment appraisal (OLV and FLV).

---

## Section 9 — Collateral Analysis

**What it contains:**
Collateral type, lien position (1st vs. 2nd), appraised value (and appraisal date), advance rate, calculated collateral coverage (collateral value × advance rate ÷ loan amount), UCC filing status, insurance requirements, and any cross-collateralization with other loans.

**Why it matters:**
Collateral is the secondary repayment source — the FRR (Facility Risk Rating / LGD proxy) is heavily driven by collateral coverage. An unsecured loan to a creditworthy borrower gets a worse FRR than a secured loan to the same borrower. OCC examiners verify that advance rates are consistent with bank policy and current appraisals.

**Evidence sources:**
Certified appraisal, title search, UCC lien search, insurance certificate (ACORD form), collateral inspection report.

**Standard advance rates (policy benchmarks):**
- Owner-occupied CRE: 75–80%
- Equipment (new): 80%
- Equipment (used): 50–60%
- Accounts receivable (eligible): 80%
- Inventory (finished goods): 50%
- Inventory (raw materials): 40%

---

## Section 10 — Guarantor Analysis

**What it contains:**
For each personal guarantor: personal financial statement (assets, liabilities, net worth), liquidity breakdown, contingent liabilities, personal tax return analysis (personal income, Schedule C/K-1 pass-throughs), and a calculation of global DSCR incorporating personal obligations.

**Why it matters:**
Personal guarantees are the tertiary repayment source for SME loans. A guarantor with negative liquidity or high personal leverage does not materially improve the credit. OCC examiners flag guarantees that are "hollow" — i.e., the guarantor could not actually repay the loan if called upon.

**Evidence sources:**
Personal financial statement (PFS) signed within 90 days, personal tax returns (2 years), personal credit report (tri-merge), personal bank statements (3 months).

---

## Section 11 — Dual Risk Rating

**What it contains:**
Two separate ratings:
- **BRR (Borrower Risk Rating):** Probability of Default (PD) — reflects the creditworthiness of the borrower entity independent of the loan structure. Typical scale: 1 (minimal risk) → 10 (loss) or 1 → 9 with Watch and Special Mention sub-grades.
- **FRR (Facility Risk Rating):** Loss Given Default (LGD) — reflects expected loss severity on the specific facility given the collateral, seniority, and structure. Drives loan loss reserve (ALLL/ACL) calculation.

The section also maps the BRR to the interagency classification: Pass (1–6), Special Mention (7), Substandard (8), Doubtful (9), Loss (10).

**Why it matters:**
The OCC's Rating Credit Risk booklet makes dual risk rating the expected standard for banks above $1B in assets (and a best practice for smaller banks). AEGIS's credit memo output must emit both a BRR and an FRR — a single "risk grade" field is insufficient.

**Evidence sources:**
Financial analysis from Sections 6–8, qualitative assessment from Sections 3–5, collateral from Section 9.

---

## Section 12 — Loan Structure, Terms, and Conditions

**What it contains:**
Full term sheet summary: loan type, amount, maturity, amortization schedule, interest rate (fixed vs. floating, index, spread, floor), prepayment penalty, fees (origination, commitment, unused), draw conditions (for revolvers), reporting requirements, and cross-default/cross-collateralization clauses.

**Why it matters:**
Structure is how risk is mitigated at the facility level. A bullet maturity on a long-lived asset creates refinance risk; a fully amortizing loan matched to asset life does not. OCC examiners look for structural mitigants proportional to identified risks.

**Evidence sources:**
Loan application, internal pricing model output, loan policy for rate floors/caps, legal counsel term sheet if syndicated.

---

## Section 13 — Covenant Package

**What it contains:**
All covenants grouped by type:

| Type | Definition | Example |
|---|---|---|
| **Financial** | Minimum/maximum ratios tested periodically | Min DSCR ≥ 1.25x; Max leverage ≤ 4.0x |
| **Reporting** | Required financial deliverables | Quarterly CPA-compiled financials within 45 days of quarter end |
| **Affirmative** | Things the borrower must do | Maintain adequate insurance; notify lender of adverse events |
| **Negative** | Things the borrower must not do | No additional senior debt without consent; no change of ownership >20% |

**Why it matters:**
Covenants are the early warning system. A well-designed covenant package trips before the loan is impaired, giving the lender time to restructure or exit. Missing covenants are a standard OCC examination deficiency.

**Evidence sources:**
Loan agreement (drafted by legal); financial covenants calibrated off the stress-tested projections in Section 7.

---

## Section 14 — Recommendation and Approval Authority

**What it contains:**
Credit officer recommendation (approve/decline/approve with conditions), conditions precedent to closing, conditions subsequent (post-closing covenants), the approval authority matrix reference (which officer or committee level has authority for this exposure size and risk grade), and signature lines.

**Why it matters:**
Documents that the correct approval authority signed off — an examiner finding that loans were approved outside policy authority is a governance deficiency. Also captures any conditions the committee imposed that differ from the officer's recommendation.

**Evidence sources:**
Internal credit policy (approval authority matrix), board-approved lending limits.
