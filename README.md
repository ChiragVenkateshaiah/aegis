# AEGIS

AI-powered credit memo / underwriting co-pilot for SME lending.

Reduces credit memo preparation time from ~6 hours to ~8 minutes by extracting financial data from messy SME documents, populating an ontology, running automated reconciliations to catch inconsistencies, computing key ratios against lender thresholds, and generating a draft memo with every claim cited back to source pages.

**Target buyer:** Credit underwriting teams at US community banks ($5B–$50B in assets) and US/UK SME lending fintechs.

**Portfolio goal:** Forward Deployed Engineer (FDE) positioning for AI labs, Palantir-style enterprise software shops, and in-house AI solutions teams at fintechs.

**Secondary goal (cert prep):** The build doubles as deliberate practice for Anthropic's **CCF-A** (Claude Certified Foundations — Architect) exam. Each phase is calibrated so its deliverables exercise specific CCF-A topics in proportion to their exam weights. See [`AGENT_PRIMER.md`](AGENT_PRIMER.md) for the per-session practice protocol and [`CCF_A_MAPPING.md`](CCF_A_MAPPING.md) for the deliverable-to-topic mapping.

> **Every session — Cowork or Claude Code — reads [`AGENT_PRIMER.md`](AGENT_PRIMER.md) first.**

---

## Repository map

```
aegis/
├── README.md                  ← you are here
├── AGENT_PRIMER.md            ← read first, every session — CCF-A practice protocol
├── CCF_A_MAPPING.md           ← deliverables ↔ CCF-A exam topics (coverage hits weights ±1%)
├── PROJECT_SPEC.md            ← living spec (source of truth, evolves)
├── PHASES.md                  ← 8-week phased plan + status (+ CCF-A topic per deliverable)
├── DECISIONS.md               ← architecture decision log
├── WORKFLOW.md                ← Cowork-plans / Claude-Code-executes workflow
├── WEEK_01_TASKS.md           ← Phase 1 / Week 1 evening blocks
├── docs/
│   ├── reference/             ← original brief + architecture/ontology SVGs
│   ├── adr/                   ← per-decision ADR markdown (one file each)
│   └── prompts/               ← chunked prompts for Claude Code CLI, per day
├── data/
│   ├── synthetic/             ← generated borrower corpus (tax returns, bank stmts)
│   ├── schemas/               ← Postgres DDL, JSON schemas for extraction
│   └── seeds/                 ← seed data for dev
├── src/aegis/
│   ├── ingestion/             ← PDF intake
│   ├── extraction/            ← Claude vision + OCR fallback
│   ├── ontology/              ← ORM, repository, queries
│   ├── reconciliation/        ← cross-document consistency checks (differentiator)
│   ├── ratios/                ← DSCR, current ratio, debt service, etc.
│   ├── memo/                  ← grounded narrative + citation engine
│   └── ui/                    ← Streamlit (or Next.js) front end
├── evals/
│   ├── harness/               ← eval framework code
│   ├── gold/                  ← gold-standard memos / extraction labels
│   └── results/               ← benchmark runs (per phase)
└── notebooks/                 ← exploration only
```

## How we build

We use a two-tool development loop documented in [WORKFLOW.md](WORKFLOW.md):

1. **Cowork (Sonnet for execution, Opus for planning)** generates chunked, phase-scoped prompts and maintains living docs.
2. **Claude Code CLI** executes those prompts inside this repository, using plan mode for non-trivial chunks.

Day 1 starts with the ontology schema. See [WEEK_01_TASKS.md](WEEK_01_TASKS.md) and [`docs/prompts/day-01-ontology-schema.md`](docs/prompts/day-01-ontology-schema.md).
