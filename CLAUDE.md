**ALWAYS read AGENT_PRIMER.md before reading anything else in this repo.**

## Project

AEGIS is an AI credit-memo co-pilot for SME lending — an 8-week dual-purpose build (FDE portfolio piece + CCF-A certification practice). Status: Phase 1 Week 1; Day 1 ontology shipped 2026-05-19. Every deliverable is load-bearing for the product AND exercises a CCF-A topic in proportion to its exam weight (T1 27% · T2 20% · T3 20% · T4 18% · T5 15%).

## File map

**Repo root (Cowork-maintained — do not edit without explicit instruction):**
`AGENT_PRIMER.md` · `PROJECT_SPEC.md` · `PHASES.md` · `WORKFLOW.md` · `CCF_A_MAPPING.md` · `DECISIONS.md` · `README.md` · `WEEK_01_TASKS.md` · `Makefile`

**`data/`** — `schemas/` (ontology.sql · erd.md · check.sh) · `seeds/` (seed_minimal.sql) · `synthetic/` (bank_statements/ · borrowers/ · tax_returns/)

**`src/aegis/`** — package stubs: `extraction/` · `ingestion/` · `memo/` · `ontology/` · `ratios/` · `reconciliation/` · `ui/`

**`evals/`** · **`notebooks/`**

**`docs/`** — `adr/` (append-only) · `prompts/` (day-chunk prompts, frozen once a chunk starts) · `reference/` (frozen — do not edit) · `posts/`

**`.claude/`** — `settings.json` · `commands/` (slash commands) · `hooks/` (hook scripts)

## Conventions

- Python 3.11+, snake_case, plural table names.
- JSONB for evidence blobs. Every fact-bearing row carries inline provenance: `source_document_id`, `page_number`, `bbox` (JSONB), `extractor_model`, `confidence` (NUMERIC 0–1), `raw_blob` (JSONB).
- Provenance FKs use `RESTRICT` cascade — losing a source document never silently deletes the evidence row citing it.
- See `docs/adr/0011-ontology-design-choices.md` for the reasoning.

## Model selection

Opus for `/plan` and architectural choices; Sonnet for execution after the plan is accepted. The move: `/model opus` → `/plan` → review → `/model sonnet` → execute. See WORKFLOW.md §"Model selection" for the full table.

## Workflow rule

"Cowork plans, Claude Code executes." Code edits land in `src/`, `evals/`, `data/`. Files at repo root are Cowork-maintained — do not edit without explicit instruction from Cowork.

## CCF-A practice rule

Every Day chunk opens with a CCF-A Practice Header (AGENT_PRIMER.md §3) and closes with a Practice Recap (§4). The mapping ledger is `CCF_A_MAPPING.md`. The per-chunk prompts live in `docs/prompts/day-NN-slug.md`.

## Common commands

```bash
make schema-apply          # apply DDL + seed to the running aegis-pg container
make schema-verify         # run data/schemas/check.sh against the aegis-pg container
docker exec aegis-pg psql -U aegis -d aegis -c '\dt'   # inspect tables from host
```

## Don't touch

- `docs/reference/` — frozen reference material.
- Root-level `*.md` files — Cowork-maintained; Claude Code does not edit these without explicit instruction.
- `docs/adr/` entries — append-only; write a new ADR rather than editing an existing one.
