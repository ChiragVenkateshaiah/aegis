# AEGIS Synthetic Borrower Persona Spec

**Version:** 1.0
**Date:** 2026-05-29
**Owner:** Cowork (Chirag)
**Status:** Frozen for Day 3 — Claude Code implements the JSON schema from this spec.
**Used by:** Day 5 corpus generation prompts; Phase 3 and Phase 5 evals.

---

## 1. Purpose

This spec defines the universe of synthetic borrower personas AEGIS will use
for corpus generation (Day 5), extraction eval (Phase 2), reconciliation testing
(Phase 3), and memo quality evaluation (Phase 5).

A persona is *not* a borrower — it is a template. The Day 5 generation step
instantiates each persona into a fully realised borrower with specific names,
numbers, and documents. The persona controls the *shape* of difficulty: which
vertical, what revenue band, which messiness traits, and what intentional
discrepancy the corpus will contain for Phase 3 to detect.

---

## 2. Verticals

Three verticals are in scope for Phase 1. Each vertical has characteristic
financial patterns that affect how a credit memo reads.

### 2.1 Services

**Definition:** B2B or B2C service businesses with no significant inventory.
Typical SIC/NAICS: professional services, IT consulting, staffing, cleaning,
logistics, healthcare services.

**Financial characteristics:**
- Revenue recognizable on invoice date (accrual) or payment receipt (cash)
- Low COGS; high gross margins (55–80%)
- Working capital driven by AR, not inventory
- Owner compensation often structured as a mix of salary + distributions

**Common underwriting concerns:**
- Revenue concentration (single client > 30% of revenue is a red flag)
- Owner as key person — business may not survive ownership transition
- AR aging: fast-paying clients vs. slow-paying government/enterprise clients

### 2.2 Retail

**Definition:** Product-based businesses selling to end consumers. Typical
NAICS: general merchandise, specialty retail, auto parts, building materials.

**Financial characteristics:**
- Revenue = sales; COGS = product cost (40–65% of revenue)
- Inventory is a balance sheet asset and a collateral item
- Seasonal cash flow patterns common (holiday, back-to-school, summer)
- Gross margins 35–60%

**Common underwriting concerns:**
- Inventory obsolescence (slow-moving SKUs, fashion cycles)
- Lease obligations (fixed rent as % of revenue)
- E-commerce competition reducing foot traffic
- Owner draws often inconsistent with stated income

### 2.3 Restaurant

**Definition:** Food service businesses — sit-down, fast casual, food truck,
catering. NAICS 722xxx.

**Financial characteristics:**
- High revenue velocity (daily cash sales)
- Very thin net margins (2–8% for well-run operations)
- Mixed payment types: cash, card, third-party delivery apps (Uber Eats, DoorDash)
- Food and labor combined = 55–70% of revenue (Prime Cost)
- High failure rate in industry; shorter loan maturities common

**Common underwriting concerns:**
- Cash-heavy operations → bank deposits may understate or overstate revenue
  depending on owner handling of cash
- Third-party delivery platform payouts (net of fees) not always reconcilable
  to gross sales on the POS system
- Lease terms and option periods are load-bearing for going-concern analysis
- Owner draws frequently mixed with operating cash

---

## 3. Revenue Bands

Three revenue bands define the size of the borrowing entity. Band affects the
typical loan size, documentation quality, and analyst time expectations.

| Band | Annual Revenue | Typical Loan Size | Documentation Quality |
|---|---|---|---|
| **Small** | $200K – $750K | $50K – $300K | Internally-prepared financials acceptable; tax returns primary |
| **Medium** | $750K – $3M | $300K – $1.5M | CPA-compiled preferred; tax returns + bank statements required |
| **Large** | $3M – $10M | $1.5M – $5M | CPA-reviewed or audited preferred; full covenant package expected |

---

## 4. Messiness Traits

Messiness traits represent realistic data quality and financial complexity
issues that make the corpus non-trivial for extraction and reconciliation.
Each persona must carry at least 2 messiness traits.

### 4.1 Revenue Messiness

| Code | Name | Description |
|---|---|---|
| `REV-SEASONAL` | Seasonal revenue | Revenue concentrated in 2–3 months; trailing-12 may misrepresent run-rate |
| `REV-LUMPY` | Lumpy contract revenue | Large contracts cause irregular monthly deposit patterns |
| `REV-MIXED-CASH` | Mixed cash/card | Cash sales handled by owner outside POS system; deposit record incomplete |
| `REV-DECLINE` | Revenue decline trend | 3-year trend shows declining revenue; current year is the worst |
| `REV-CONCENTRATION` | Client concentration | Single client > 35% of revenue; customer loss is an existential event |

### 4.2 Expense and Margin Messiness

| Code | Name | Description |
|---|---|---|
| `EXP-ADDBACKS` | Owner expense addbacks | Personal expenses run through business P&L (vehicle, travel, phone) |
| `EXP-NON-RECURRING` | Non-recurring items | Large one-time expense (equipment write-off, legal settlement) distorts margins |
| `EXP-RECLASSIFY` | Reclassification needed | COGS / SG&A split inconsistent across years; requires analyst normalization |

### 4.3 Owner Draw and Compensation Messiness

| Code | Name | Description |
|---|---|---|
| `OWN-EXCESS-DRAWS` | Excess owner draws | Draws taken exceed declared owner compensation; visible in bank outflows |
| `OWN-SUPPRESSED` | Suppressed compensation | Owner pays themselves below market rate to inflate net income |
| `OWN-MIXED-PERSONAL` | Personal/business mixing | Personal transactions in the operating account; commingled cash |

### 4.4 Balance Sheet and Debt Messiness

| Code | Name | Description |
|---|---|---|
| `BS-RELATED-PARTY` | Related-party receivables | AR includes amounts owed by entities related to the owner; collectibility uncertain |
| `BS-INTANGIBLES` | Goodwill / intangibles | Acquisition-related goodwill; write-down risk if business underperforms |
| `BS-UNDISCLOSED-DEBT` | Undisclosed debt | A debt obligation visible in bank statement outflows is not on the tax return |
| `BS-STALE-APPRAISAL` | Stale collateral appraisal | Real estate or equipment appraisal > 18 months old; current value uncertain |

### 4.5 Document Quality Messiness

| Code | Name | Description |
|---|---|---|
| `DOC-PRIOR-YEAR-ONLY` | Missing current year | Current year financials are not yet available; prior year is 18+ months stale |
| `DOC-INTERNAL-ONLY` | Internally prepared only | No CPA involvement; financials are owner-prepared; reliability risk |
| `DOC-FISCAL-YEAR` | Non-calendar fiscal year | Fiscal year ends on a non-December date; requires period realignment |
| `DOC-RESTATEMENT` | Prior year restatement | A prior year return was amended; the original and amended versions differ |

---

## 5. Intentional Discrepancies

Every persona must have exactly one intentional discrepancy — a specific
inconsistency between two document types that Phase 3 (reconciliation) is
expected to detect and flag. The discrepancy is parameterised so the generation
prompt can instantiate it with concrete numbers.

| Code | Name | Documents involved | What to look for |
|---|---|---|---|
| `DISC-REV-DEP` | Revenue vs. deposit gap | Tax return ↔ bank statements | Declared revenue exceeds annualised deposits by > 15% |
| `DISC-DRAW-OUTFLOW` | Draw vs. outflow gap | Tax return ↔ bank statements | Declared owner compensation < actual recurring outflows to owner |
| `DISC-DEBT-UNDISCLOSED` | Undisclosed debt obligation | Bank statements ↔ tax return | Recurring outflow pattern consistent with debt service not present in stated liabilities |
| `DISC-COLLATERAL-STALE` | Stale collateral value | Appraisal ↔ current market | Appraisal used in memo is > 24 months old; market conditions have deteriorated |

---

## 6. Owner Profile

Each persona specifies a single principal owner. The owner profile feeds the
guarantor analysis section of the credit memo (Section 10).

**Fields:**
- `ownership_pct` (numeric, 0–100): percentage of business owned by the principal
- `years_in_industry` (integer): years of experience in the vertical
- `key_person_risk` (boolean): is the owner the sole operational key person?
- `personal_credit_profile` (enum): `strong` (720+) | `adequate` (660–719) | `weak` (< 660)
- `personal_liquidity` (enum): `high` (> 6 months personal obligations) | `moderate` (3–6 months) | `low` (< 3 months)
- `hollow_guarantee_risk` (boolean): would the personal guarantee be practically unenforceable?

---

## 7. Loan Request Parameters

Each persona carries a baseline loan request. The generation step instantiates
specific numbers within these ranges.

**Fields:**
- `loan_type` (enum): `term_loan` | `revolving_loc` | `equipment_loan` | `sba_7a`
- `loan_purpose` (enum): `working_capital` | `equipment_purchase` | `real_estate` | `acquisition` | `refinance` | `expansion`
- `requested_amount_band` (enum): `small` | `medium` | `large` (maps to §3 revenue bands)
- `collateral_type` (enum): `owner_occupied_cre` | `equipment` | `ar_inventory` | `unsecured` | `mixed`
- `guarantor_count` (integer, 1–3): number of personal guarantors

---

## 8. Difficulty Rating

Each persona carries a difficulty rating for the overall underwriting challenge
it presents. Difficulty is a function of messiness trait count, discrepancy
severity, and financial trend.

| Rating | Description | Intended use |
|---|---|---|
| `easy` | Clean financials, strong borrower, no trend concerns | Baseline / smoke test |
| `moderate` | 2–3 messiness traits, one borderline ratio, one discrepancy | Standard eval case |
| `hard` | 4+ messiness traits, deteriorating trend, material discrepancy | Stress test / edge case |

---

## 9. Persona ID Convention

Personas are identified by a zero-padded 3-digit integer followed by a slug:

```
{NNN}-{vertical}-{difficulty}
```

Examples:
- `001-services-easy`
- `002-retail-moderate`
- `003-restaurant-hard`

The JSON filename follows: `persona-{NNN}-{vertical}.json`

---

## 10. Fields reference (flat list for schema implementation)

This is the canonical field list Claude Code will use to implement
`data/schemas/persona.schema.json`.

```
persona_id          string   required   e.g. "001-services-easy"
vertical            enum     required   "services" | "retail" | "restaurant"
revenue_band        enum     required   "small" | "medium" | "large"
difficulty          enum     required   "easy" | "moderate" | "hard"

# Financial profile
revenue_trend       enum     required   "growing" | "stable" | "declining"
gross_margin_band   enum     required   "low" (<35%) | "medium" (35-60%) | "high" (>60%)
dscr_band           enum     required   "strong" (>1.50x) | "adequate" (1.20-1.50x) | "thin" (1.00-1.20x) | "insufficient" (<1.00x)
leverage_band       enum     required   "low" (<2x) | "moderate" (2-4x) | "high" (>4x)

# Messiness
messiness_traits    array    required   min 2 items; values from §4 codes
primary_discrepancy enum     required   one value from §5 codes
discrepancy_magnitude enum   required   "minor" (<10%) | "moderate" (10-25%) | "material" (>25%)

# Owner profile
owner_ownership_pct         number   required   0–100
owner_years_in_industry     integer  required
owner_key_person_risk       boolean  required
owner_personal_credit       enum     required   "strong" | "adequate" | "weak"
owner_personal_liquidity    enum     required   "high" | "moderate" | "low"
owner_hollow_guarantee_risk boolean  required

# Loan request
loan_type           enum     required   "term_loan" | "revolving_loc" | "equipment_loan" | "sba_7a"
loan_purpose        enum     required   "working_capital" | "equipment_purchase" | "real_estate" | "acquisition" | "refinance" | "expansion"
requested_amount_band enum   required   "small" | "medium" | "large"
collateral_type     enum     required   "owner_occupied_cre" | "equipment" | "ar_inventory" | "unsecured" | "mixed"
guarantor_count     integer  required   1–3

# Narrative hooks (for generation prompts)
business_description  string  required   1–2 sentence plain-English description of the business
key_risk_narrative    string  required   1–2 sentence plain-English summary of the primary underwriting risk
discrepancy_description string required  1 sentence describing the specific inconsistency the generation prompt should embed
```
