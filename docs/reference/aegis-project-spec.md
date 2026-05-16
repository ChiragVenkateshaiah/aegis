# AEGIS — Project Brief & Cowork Kickoff

> **Use this as the starting prompt for Cowork.** Paste it in full as your first message. It captures the context, strategic decisions, v1 spec, and 8-week phased plan we've already locked in. From here, Cowork should help me maintain documentation, track phases, and execute each weekly deliverable.

---

## Who I am and what I'm building

I'm a Business Analyst with 5 years of experience, now working as an AI Engineer with Databricks Data Engineering skills. I work at a Palantir-style company building CSM-domain solutions with Claude Code.

I'm building **AEGIS** as a portfolio project to position myself for Forward Deployed Engineer (FDE) roles at AI labs (Anthropic, OpenAI, Scale AI), Palantir-style enterprise software shops, or in-house AI solutions teams at fintechs. My current CSM project covers the software-domain side; AEGIS adds a second domain (financial services) to demonstrate range — exactly the "ramps fast on new verticals" signal Palantir-style hiring managers look for.

## Strategic decisions already made

**Domain:** Financial document workflows in SME credit underwriting.

**Why this domain:** AI is genuinely transformative here (not cosmetic), domain knowledge is a moat that compounds across my career, my prior BA exposure to fintech onboarding gives me a foothold, and finance-specialized FDEs earn at the top of the band ($250-500K+ at senior levels at the best AI-x-finance shops).

**Target buyer:** Credit underwriting teams at US community banks ($5B-$50B in assets) and US/UK SME lending fintechs. Indian NBFCs (Lendingkart, Indifi, FlexiLoans) are a clear secondary market — the same product translates with minor adaptation.

**Why this buyer over Indian-first:** Software budgets 10-50x larger, which means the ROI math in my case study reads "saves $400/memo × 50,000 memos/year = $20M unlocked" instead of "saves ₹2,000/memo." That higher dollar number is what justifies $300K+ FDE offers in interviews. Public datasets (FDIC, SEC EDGAR, OCC/FFIEC/RMA templates) are available. Casca and similar AI-underwriting startups have raised substantial rounds for this exact market, validating it.

## The product

**Aegis** is an AI-powered credit memo / underwriting co-pilot for SME lending. It reduces credit memo preparation time from ~6 hours per memo to ~8 minutes by extracting financial data from messy SME documents, populating an ontology, running automated reconciliations to catch inconsistencies, computing key ratios against lender thresholds, and generating a draft memo with every claim cited back to source pages.

**The 60-second demo (the forcing function for v1):**
A credit analyst at a $20B community bank receives an SME loan application — a small services business asking for $400K. Drag-and-drop two PDFs (business tax return + 6 months of bank statements) into Aegis. The ontology populates live. The analyst sees a pre-populated credit memo with every claim citing back to specific PDF pages, three exception flags highlighted including "Reported revenue $2.4M, bank deposits suggest $1.7M — flag for review." Analyst clicks the flag, sees the discrepancy with source pages highlighted. One edit, approve, send to committee. Eight minutes elapsed vs. six hours traditionally.

## The differentiators (be religious about these)

1. **Reconciliation engine** — Every other AI underwriting demo extracts and summarizes. Aegis catches inconsistencies *across* documents. This is the moment in the demo where a hiring manager sits up.
2. **Eval framework with real numbers** — "94% field-level extraction accuracy, 87% precision on exception flags, 4.2/5 memo quality vs. analyst gold standard on 30 hold-out cases." Most portfolio projects can't say anything like this.

## v1 components (8)

1. **Document ingestion** — Two doc types only: business tax return (1120, 1120S, or 1065) + business bank statements. Skip personal returns and audited financial statements for v1.
2. **Extraction layer** — Claude (vision) + OCR fallback, structured outputs with per-field confidence scores.
3. **Ontology** — Borrower → Entity → FinancialPeriod → TaxReturn/BankStatement → LineItem → Ratio → Reconciliation → ExceptionFlag → Memo. Postgres-backed.
4. **Reconciliation engine** *(differentiator)* — Three checks for v1: (a) tax return revenue vs. bank deposits, (b) declared owner draws vs. actual bank withdrawals, (c) debt-to-income consistency across documents.
5. **Ratio + risk engine** — 5-6 ratios that matter for SME credit: DSCR, current ratio, debt service ratio, working capital, owner debt-to-income. Real community bank thresholds.
6. **Memo generation** — LLM narrative grounded in the ontology, every claim cited to source pages. Simplified OCC-style template.
7. **Analyst UI** — Streamlit for iteration speed (or Next.js if I want a more polished product look).
8. **Eval framework** *(differentiator)* — Hold-out set of 20-30 borrower applications with gold-standard memos. Measured: per-field extraction accuracy, ratio calc accuracy, exception-flag precision/recall, end-to-end memo quality (rubric + LLM-as-judge + human spot-check).

## Data strategy

- **SEC EDGAR** filings for realistic financial statement structures (public companies, but formats teach the right patterns).
- **LLM-synthesized SME tax returns and bank statements** based on real templates — generate 30-50 borrower personas across services, retail, and restaurant verticals with internally-consistent financials including realistic messiness (write-offs, owner draws, seasonal patterns).
- **Public credit memo templates** from OCC, FFIEC, RMA materials.

Databricks pipelines handle data generation, ingestion, and eval — authentic data engineering, not decoration.

## 8-week phased plan (evenings + weekends)

| Phase | Week | Deliverable |
|---|---|---|
| Phase 1: Foundation | Week 1 | Read first half of Ittelson; study a real credit memo template; generate synthetic borrower corpus; lock ontology schema (Postgres DDL). No production code beyond data generation. |
| Phase 2: Extraction | Weeks 2-3 | PDF → structured data pipeline for both doc types. Benchmark extraction accuracy on hold-out set. |
| Phase 3: Reasoning | Weeks 4-5 | Reconciliation engine (3 checks) + ratio engine. This is the showcase work — budget the time. |
| Phase 4: Synthesis | Week 6 | Memo generation with citations + analyst UI (Streamlit). |
| Phase 5: Measurement | Weeks 7-8 | Eval framework, run benchmarks, record 60-second demo video, write case study with ROI math. |

## Required reading

- **Primary:** *Financial Statements* by Thomas Ittelson (foundation — read in evenings across weeks 1-3)
- **Secondary:** *The Bank Credit Analysis Handbook* by Jonathan Golin (credit-specific frameworks — read after Ittelson)
- **Supplementary:** Aswath Damodaran's free YouTube finance courses

## What I need Cowork to help me with

1. **Maintain a living spec document** — keep this brief updated as decisions evolve.
2. **Phase tracking** — track progress through the 8-week plan with weekly check-ins on deliverables.
3. **Task management** — break each phase into concrete tasks I can complete in 2-3 hour evening blocks.
4. **Artifact management** — keep all project files (synthetic corpus, ontology schema, eval results, code, demo video script, case study draft) organized.
5. **Decision log** — record any architectural or strategic decisions made during the build so I can reference them later when writing the case study.

## Where we are right now

Planning complete. About to start Phase 1, Week 1.

**First Week 1 task to nail down:** Which deliverable to tackle first — ontology schema, demo storyboard, synthetic corpus generation, or full spec doc. Let's decide together, then get started.
