# AEGIS — Phased Plan

> 8-week plan. Evenings + weekends. Update status as we go. Each phase ends with a **milestone commit** to the decision log.

**Legend:** ☐ not started · ◐ in progress · ✅ done · ✖ skipped

---

## Phase 1 — Foundation (Week 1)

**Goal:** Lock the data model, understand the domain, generate the synthetic corpus seed.
**Status:** ◐ in progress (Day 1: ontology schema)

| # | Deliverable | Status | Notes |
|---|---|---|---|
| 1.1 | Read first half of Ittelson (Chapters 1–8) | ☐ | Evenings |
| 1.2 | Study a real credit memo template (OCC) | ☐ | 1 evening block |
| 1.3 | **Ontology schema — Postgres DDL** | ◐ | **Day 1 — see WEEK_01_TASKS.md** |
| 1.4 | Synthetic borrower persona spec (30–50 personas) | ☐ | services / retail / restaurant |
| 1.5 | Generate v0 synthetic corpus (3 borrowers end-to-end as smoke test) | ☐ | end of week |
| 1.6 | Lock data dictionary (per ontology table) | ☐ | derives from 1.3 |

**Phase exit criteria:**
- Ontology DDL applies cleanly to a fresh Postgres instance, with seed data.
- Data dictionary published.
- 3-borrower smoke corpus generated and inspectable.
- ADRs recorded for ontology design + data strategy.

---

## Phase 2 — Extraction (Weeks 2–3)

**Goal:** PDF → structured ontology rows, with confidence scores. Hit ≥ 90% field accuracy on a small hold-out before exiting.
**Status:** ☐

| # | Deliverable | Status | Notes |
|---|---|---|---|
| 2.1 | Ingestion pipeline (PDF intake + page rendering) | ☐ | |
| 2.2 | Tax-return extractor (1120 / 1120S / 1065) | ☐ | Claude vision primary |
| 2.3 | Bank-statement extractor (transactions + summary) | ☐ | |
| 2.4 | Confidence-score schema + persistence | ☐ | |
| 2.5 | OCR fallback path | ☐ | pdfplumber / Tesseract |
| 2.6 | Mini eval: per-field accuracy on 10 borrowers | ☐ | gate to Phase 3 |

**Phase exit criteria:**
- ≥ 90% field-level extraction accuracy on the mini hold-out.
- All extracted facts land in the ontology with provenance (file + page + bbox).

---

## Phase 3 — Reasoning (Weeks 4–5)  ← **showcase work**

**Goal:** Reconciliation engine + ratios. This is the differentiator — budget the time.
**Status:** ☐

| # | Deliverable | Status | Notes |
|---|---|---|---|
| 3.1 | Reconciliation check #1 — tax return revenue vs. bank deposits | ☐ | |
| 3.2 | Reconciliation check #2 — declared owner draws vs. bank withdrawals | ☐ | |
| 3.3 | Reconciliation check #3 — debt-to-income consistency | ☐ | |
| 3.4 | Ratio engine (DSCR, current ratio, debt service, working capital, owner DTI) | ☐ | community-bank thresholds |
| 3.5 | Exception-flag schema + severity grading | ☐ | |
| 3.6 | Mid-phase eval: flag precision / recall | ☐ | |

**Phase exit criteria:**
- All 3 reconciliations produce structured ExceptionFlag rows with explanations.
- Ratios computed with thresholds and verdicts.
- Precision ≥ 85% on a small flagged-vs-truth set.

---

## Phase 4 — Synthesis (Week 6)

**Goal:** Generate the memo + ship the analyst UI.
**Status:** ☐

| # | Deliverable | Status | Notes |
|---|---|---|---|
| 4.1 | Memo template (simplified OCC) | ☐ | |
| 4.2 | Citation engine (every claim → source page) | ☐ | |
| 4.3 | Memo generation pipeline | ☐ | |
| 4.4 | Streamlit UI — upload, ontology view, memo, flag panel | ☐ | |

**Phase exit criteria:**
- End-to-end run: 2 PDFs → ontology populated → flags surfaced → memo drafted with citations.
- ≤ 8 min wall-clock on the demo machine.

---

## Phase 5 — Measurement (Weeks 7–8)

**Goal:** Eval framework, benchmarks, demo video, case study.
**Status:** ☐

| # | Deliverable | Status | Notes |
|---|---|---|---|
| 5.1 | Gold-standard set: 20–30 borrowers w/ analyst-graded memos | ☐ | |
| 5.2 | Eval harness (per-field acc, ratio acc, flag P/R, memo quality) | ☐ | |
| 5.3 | LLM-as-judge for memo quality | ☐ | rubric + spot-check |
| 5.4 | Benchmark run + results table | ☐ | hit the targets in PROJECT_SPEC §9 |
| 5.5 | 60-second demo video | ☐ | |
| 5.6 | Case study writeup with ROI math | ☐ | |

**Phase exit criteria — and v1 ship criteria:**
- All metrics in PROJECT_SPEC §9 hit.
- Demo video recorded.
- Case study published (LinkedIn + portfolio site).
