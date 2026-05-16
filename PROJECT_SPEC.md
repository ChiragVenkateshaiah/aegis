# AEGIS — Living Project Specification

> **Status:** Active. This is the source of truth. Update whenever a decision changes.
> **Last updated:** 2026-05-16
> **Owner:** Chirag

---

## 1. Vision

Aegis is an AI-powered credit memo / underwriting co-pilot for SME lending. It reduces credit memo preparation time from **~6 hours per memo to ~8 minutes** by:

1. Extracting financial data from messy SME documents
2. Populating a structured ontology
3. Running automated reconciliations to catch cross-document inconsistencies
4. Computing key ratios against lender thresholds
5. Generating a draft memo with every claim cited back to source pages

## 2. The 60-second demo (v1 forcing function)

A credit analyst at a $20B community bank receives an SME loan application — a small services business asking for $400K. They drag-and-drop two PDFs (business tax return + 6 months of bank statements) into Aegis. The ontology populates live. They see a pre-populated credit memo with every claim citing back to specific PDF pages, **three exception flags** highlighted including *"Reported revenue $2.4M, bank deposits suggest $1.7M — flag for review."* The analyst clicks the flag, sees the discrepancy with source pages highlighted. One edit, approve, send to committee. **Eight minutes elapsed vs. six hours traditionally.**

## 3. Target buyer

- **Primary:** Credit underwriting teams at US community banks ($5B–$50B in assets).
- **Primary:** US/UK SME lending fintechs.
- **Secondary:** Indian NBFCs (Lendingkart, Indifi, FlexiLoans) — translates with minor adaptation.

**Why US/UK over India-first:** Software budgets are 10–50× larger. ROI math in the case study reads *"saves $400/memo × 50,000 memos/year = $20M unlocked"* rather than `₹2,000/memo`. That higher dollar figure is what justifies $300K+ FDE offers in interviews.

## 4. Strategic positioning

| Dimension | Decision |
|---|---|
| Domain | Financial document workflows in SME credit underwriting |
| Why this domain | Genuinely transformative (not cosmetic); domain knowledge is a moat that compounds; my prior BA fintech onboarding exposure gives a foothold; finance-specialized FDEs earn at the top of the band |
| Portfolio role | Adds a second domain (financial services) to my existing CSM-domain work — demonstrates "ramps fast on new verticals" signal |

## 5. Differentiators (be religious about these)

1. **Reconciliation engine.** Every other AI underwriting demo extracts and summarizes. Aegis catches inconsistencies *across* documents. This is the moment in the demo where a hiring manager sits up.
2. **Eval framework with real numbers.** Aegis ships with measured accuracy: target *"94% field-level extraction accuracy, 87% precision on exception flags, 4.2/5 memo quality vs. analyst gold standard on 30 hold-out cases."* Most portfolio projects can't say anything like this.

## 6. v1 components

1. **Document ingestion** — Two doc types only for v1: business tax return (1120, 1120S, or 1065) + business bank statements. Personal returns and audited financial statements deferred.
2. **Extraction layer** — Claude (vision) + OCR fallback, structured outputs with per-field confidence scores.
3. **Ontology** — Borrower → Entity → FinancialPeriod → TaxReturn / BankStatement → LineItem → Ratio → Reconciliation → ExceptionFlag → Memo. Postgres-backed.
4. **Reconciliation engine** *(differentiator)* — Three checks for v1:
   - (a) tax return revenue vs. bank deposits
   - (b) declared owner draws vs. actual bank withdrawals
   - (c) debt-to-income consistency across documents
5. **Ratio + risk engine** — 5–6 ratios that matter for SME credit: DSCR, current ratio, debt service ratio, working capital, owner debt-to-income. Real community bank thresholds.
6. **Memo generation** — LLM narrative grounded in the ontology; every claim cited to source pages. Simplified OCC-style template.
7. **Analyst UI** — Streamlit (iteration speed) with optional Next.js polish pass for the demo video.
8. **Eval framework** *(differentiator)* — Hold-out set of 20–30 borrower applications with gold-standard memos. Measured: per-field extraction accuracy, ratio calc accuracy, exception-flag precision/recall, end-to-end memo quality (rubric + LLM-as-judge + human spot-check).

## 7. Data strategy

- **SEC EDGAR** filings for realistic financial statement structures (public companies, but formats teach the right patterns).
- **LLM-synthesized SME tax returns and bank statements** based on real templates — 30–50 borrower personas across **services, retail, and restaurant** verticals with internally-consistent financials including realistic messiness (write-offs, owner draws, seasonal patterns).
- **Public credit memo templates** from OCC, FFIEC, RMA materials.
- **Databricks pipelines** handle data generation, ingestion, and eval — authentic data engineering, not decoration.

## 8. Tech stack (v1)

| Layer | Choice | Rationale |
|---|---|---|
| Language | Python 3.11+ | Standard for ML/data tooling |
| DB | Postgres | Ontology-native; JSONB for evidence blobs |
| Extraction | Claude (vision) + Tesseract / pdfplumber fallback | Vision for messy PDFs, OCR for clean ones |
| Pipelines | Databricks (synthetic data + eval batch) | Demonstrates DE skill |
| UI | Streamlit (Next.js optional polish) | Speed > aesthetics for v1 |
| Eval | Custom harness + LLM-as-judge | Quoted numbers are the differentiator |

## 9. Success criteria for v1

| Metric | Target |
|---|---|
| Field-level extraction accuracy | ≥ 94% |
| Exception-flag precision | ≥ 87% |
| Exception-flag recall | ≥ 80% |
| Memo quality (1–5 rubric, blind) | ≥ 4.2/5 |
| End-to-end runtime (2 PDFs → memo) | ≤ 8 min |
| Hold-out set size | 20–30 borrower applications |

## 10. Out of scope for v1

- Personal tax returns (1040)
- Audited financial statements / 10-K parsing
- Real banking system integrations
- Multi-user / RBAC
- Production-grade observability
- Mobile UI

## 11. Open questions

- [ ] Streamlit vs. Next.js for the demo recording — decide by end of Phase 3.
- [ ] Confidence-score calibration approach: per-field model output vs. ensemble cross-check.
- [ ] How aggressively to filter false-positive exception flags vs. let the analyst dismiss.
- [ ] Whether to include a personal-guarantor signal track in v1 (Indian NBFCs care more about this).

## 12. Required reading

- **Primary:** *Financial Statements* by Thomas Ittelson (evenings, weeks 1–3)
- **Secondary:** *The Bank Credit Analysis Handbook* by Jonathan Golin
- **Supplementary:** Aswath Damodaran's free YouTube finance courses

## 13. Reference artifacts

- [`docs/reference/aegis-project-spec.md`](docs/reference/aegis-project-spec.md) — original handover brief (frozen)
- [`docs/reference/aegis-architecture.svg`](docs/reference/aegis-architecture.svg)
- [`docs/reference/aegis-ontology.svg`](docs/reference/aegis-ontology.svg)
