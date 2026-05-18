# AEGIS — Decision Log

> Lightweight ADRs. Each row links to a fuller record in `docs/adr/NNNN-slug.md` when the reasoning warrants it.
> Add a row whenever a decision is made that future-Chirag might second-guess.

| # | Date | Decision | Status | Rationale (one-liner) | ADR |
|---|---|---|---|---|---|
| 0001 | 2026-05-16 | Domain = SME credit underwriting (financial services) | Accepted | Genuinely transformative, compounds career capital, prior BA fintech exposure, top of FDE pay band | — |
| 0002 | 2026-05-16 | Target buyer = US community banks ($5B–$50B AUM) + US/UK SME fintechs | Accepted | 10–50× software budgets vs. India-first means the ROI story justifies $300K+ FDE offers | — |
| 0003 | 2026-05-16 | v1 doc types = business tax return + business bank statements only | Accepted | Two doc types is enough for the demo; 1040 + audited stmts deferred | — |
| 0004 | 2026-05-16 | Reconciliation engine is the lead differentiator (not extraction) | Accepted | Extraction is commodity; cross-doc inconsistency catches is what makes a hiring manager sit up | — |
| 0005 | 2026-05-16 | Postgres-backed ontology (not a vector store or doc DB as primary) | Accepted | Relational integrity matters for cited memos; JSONB handles evidence blobs | — |
| 0006 | 2026-05-16 | Synthetic corpus via LLM, grounded in real templates + SEC EDGAR | Accepted | No SME dataset is publicly licensed; synthetic is auditable and we control messiness | — |
| 0007 | 2026-05-16 | Stack = Python + Postgres + Streamlit (v1), Databricks for pipelines | Accepted | Iteration speed; DBX demonstrates DE skill on the resume | — |
| 0008 | 2026-05-16 | Dev workflow = Cowork plans, Claude Code CLI executes | Accepted | See WORKFLOW.md. Chunked per-phase prompts; plan mode for non-trivial chunks | — |
| 0009 | 2026-05-16 | Day 1 deliverable = ontology Postgres DDL | Accepted | Contract-first; extraction/reconciliation/memo all bind to the ontology | [docs/adr/0009-day1-ontology-first.md](docs/adr/0009-day1-ontology-first.md) |
| 0010 | 2026-05-16 | Folder layout = standard (docs/data/src/evals/notebooks) | Accepted | Industry-standard; survives the project growing past Week 3 | — |
| 0011 | 2026-05-16 | Ontology design choices (inheritance model, provenance shape, FK cascades) | Reserved | Slot reserved; written by Claude Code CLI after Day 1 execution per WEEK_01_TASKS.md | [docs/adr/0011-ontology-design-choices.md](docs/adr/0011-ontology-design-choices.md) (planned) |
| 0012 | 2026-05-16 | AEGIS is dual-purpose: FDE portfolio piece + CCF-A exam practice | Accepted | Practice surface area is calibrated to exam weights (T1 27 / T2 20 / T3 20 / T4 18 / T5 15) within ±1%; mapping lives in CCF_A_MAPPING.md, primer lives in AGENT_PRIMER.md | [docs/adr/0012-ccf-a-syllabus-mapping.md](docs/adr/0012-ccf-a-syllabus-mapping.md) |

---

## Adding a new ADR

1. Add a row to the table above (one-line rationale).
2. If the decision is non-trivial (architectural, strategic, or reversible-but-costly), create `docs/adr/NNNN-slug.md` using the template below.

### ADR template

```markdown
# ADR-NNNN: <Title>

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Superseded by ADR-XXXX | Deprecated

## Context
What forces are at play? What's the problem we're solving right now?

## Decision
The thing we're doing.

## Alternatives considered
- Option A — why rejected
- Option B — why rejected

## Consequences
- Positive: ...
- Negative / tradeoffs: ...
- Follow-ups required: ...
```
