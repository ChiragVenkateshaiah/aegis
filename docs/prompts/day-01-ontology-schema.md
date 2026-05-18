# Day 1 — Ontology Postgres DDL

**Phase:** 1 — Foundation
**Week:** 1
**Spec sections:** PROJECT_SPEC §6 (component 3 — Ontology), §8 (Tech stack)
**Estimated time:** ~3h
**Mode in Claude Code CLI:** `/plan` first, then execute. The chunk introduces a new schema and touches multiple files — plan mode is mandatory.

---

## Paste-this prompt for Claude Code CLI

> Open Claude Code CLI inside the `aegis/` repo, run `/plan`, then paste everything inside the fenced block below. Review the plan, accept it (or push back), and let it execute. Stop and ask before any decision that's not explicitly answered here.

```text
═══════════════ CCF-A PRACTICE HEADER ═══════════════
Chunk:        Day 01 — Ontology Postgres DDL
Phase:        1 — Foundation

PRIMARY topic practiced this chunk:
  [T5] Context Management & Reliability (15%)
  Why this chunk: We design the provenance substrate — every fact-bearing row
  carries (document, page, bbox, model, confidence, raw_blob). This *is* the
  reliability backbone every later module binds to. Get the evidence model
  wrong here and reliability work in Phase 5 has nothing to land on.

SECONDARY topics touched (lighter practice):
  — (none — keep the focus clean on Day 1)

DELIBERATELY NOT PRACTICED HERE (do not chase):
  [T1] Agentic Architecture & Orchestration — no agents yet; this is schema
  [T2] Claude Code Configuration & Workflows — CLAUDE.md and slash commands land in Day 1.5+
  [T3] Prompt Engineering & Structured Output — no LLM prompts in this chunk
  [T4] Tool Design & MCP Integration — MCP servers start in Phase 2

CCF-A coverage cross-ref: CCF_A_MAPPING.md §4 row 1.3
═══════════════════════════════════════════════════════

You are working inside the AEGIS repository, an AI-powered credit memo / underwriting co-pilot for SME lending. Today is Day 1 of an 8-week build. Read AGENT_PRIMER.md first (it explains the CCF-A practice header above and why this chunk has only T5 as primary). Then read PROJECT_SPEC.md, PHASES.md, DECISIONS.md, WORKFLOW.md, WEEK_01_TASKS.md, CCF_A_MAPPING.md, and docs/adr/0009-day1-ontology-first.md before doing anything else. Also read docs/reference/aegis-project-spec.md and docs/reference/aegis-ontology.svg for visual context.

## Goal
Produce a production-shaped Postgres 16 DDL for the AEGIS ontology, along with a text ERD, a minimal seed, and a package stub. This is contract-first work: every later module (extraction, reconciliation, ratios, memo) will bind to these tables. Get the contract right.

## Required entities and relationships
At minimum, model the following. Use sensible field types; ask before adding fields that aren't obvious from the brief.

1. borrower                       — the legal applicant
2. entity                         — the operating business (a borrower can have one or more)
3. financial_period               — a quarter, year, or arbitrary span
4. document                       — abstract source PDF (tax return or bank statement)
5. tax_return                     — a 1120 / 1120S / 1065 instance (extends document)
6. bank_statement                 — a monthly statement (extends document)
7. line_item                      — an extracted financial fact (revenue, expense, deposit, etc.)
8. ratio                          — a computed ratio (DSCR, current ratio, debt service, working capital, owner DTI)
9. reconciliation                 — a cross-document check instance (3 kinds for v1)
10. exception_flag                — a surfaced inconsistency or threshold breach
11. memo                          — the generated credit memo
12. memo_citation                 — claim → source page/bbox linkage

Pick the inheritance approach you prefer between tax_return / bank_statement / document — single table with type discriminator vs. table-per-subtype — but write an ADR justifying the call.

## Evidence / provenance is mandatory
Every fact-bearing row (line_item, ratio inputs, reconciliation result, exception_flag, memo_citation) must record:
- source document_id
- page number (1-indexed)
- bounding box (JSONB, optional)
- extractor model + version
- per-field confidence (numeric 0–1)
- raw extracted blob (JSONB) for re-derivation

Confidence and provenance are not afterthoughts — they're load-bearing for the case study.

## Constraints
- Postgres 16. Use JSONB freely for blobs, but keep queryable fields as proper columns.
- All tables: surrogate UUID primary keys (gen_random_uuid()), created_at / updated_at timestamps with timezone, soft-delete-friendly (deleted_at nullable) but do not implement soft-delete logic — just the column.
- Foreign keys with ON DELETE behavior chosen deliberately per relationship (document the choice in comments).
- Indexes for the obvious query paths: borrower lookups, document → line_items, exception_flag by severity + status, memo → citations.
- snake_case naming. Plural table names.
- No ORM yet — pure SQL DDL. We add an ORM in Phase 2.

## Deliverables (write these files)
1. data/schemas/ontology.sql       — the DDL, idempotent (CREATE TABLE IF NOT EXISTS or wrapped in a transaction with explicit DROP/CREATE behind a guard flag).
2. data/schemas/erd.md             — text ERD (Mermaid block) + one short paragraph per table.
3. data/seeds/seed_minimal.sql     — inserts one fake borrower end-to-end: 1 borrower, 1 entity, 1 financial_period, 1 tax_return doc, 1 bank_statement doc, ~5 line_items across them, 1 ratio, 1 reconciliation, 1 exception_flag, 1 memo with 2 citations. Values can be obviously fake (Acme LLC), but should be schema-valid.
4. src/aegis/ontology/__init__.py  — empty package marker with a module docstring explaining what will live here later.
5. docs/adr/0011-ontology-design-choices.md — written *after* you've made decisions, capturing: (a) inheritance model for documents, (b) provenance column shape, (c) any FK-cascade calls you made, (d) what you intentionally did NOT model in v1.
6. Makefile target `schema-apply` that runs the DDL + seed against a local Postgres (assume DATABASE_URL env var).

## Acceptance check
Spin up a fresh Postgres 16 container, point DATABASE_URL at it, run `make schema-apply`, and verify:
- Zero SQL errors.
- All expected tables exist (psql \dt).
- The seed inserts produce exactly the row counts implied above.
- A one-line sanity query joining memo → memo_citation → line_item → document returns 2 rows.

Add a tiny shell script `data/schemas/check.sh` that runs the verification and exits non-zero on failure. Run it before declaring done.

## Open questions — pause and ask before deciding
- Should financial_period support overlapping ranges (e.g., trailing-12-month windows that overlap quarterly periods)? Default to yes unless you see a reason not to.
- Should we model owner / personal guarantor in v1? Default to a minimal `owner` table linked to entity, but flag in the ADR that we may expand in Phase 3.
- Currency: assume USD-only v1, but include a currency column on monetary fields so we don't have to migrate later.

## When you're done
1. Print a summary diff of files created.
2. Print the `psql \dt` output from your verification.
3. Tell me what's in the ADR's "intentionally not modeled" section.
4. STOP. Do not advance to Day 2. The next prompt comes from Cowork.
```

---

## Operator checklist (back in Cowork after Claude Code CLI finishes)

- [ ] Flip Phase 1 row 1.3 to ✅ in `PHASES.md`.
- [ ] Append a row to `DECISIONS.md` if Claude Code CLI made any meaningful schema-shape calls (inheritance model, cascade behavior).
- [ ] Read `docs/adr/0011-ontology-design-choices.md` and add follow-ups to `PROJECT_SPEC.md §11` if any.
- [ ] **Fill in the Practice Recap below** (template in `AGENT_PRIMER.md §4`).
- [ ] Draft `docs/prompts/day-02-credit-memo-template.md` (Cowork, Sonnet is fine for this one).

---

## Practice Recap — Day 01

> Fill in after Claude Code CLI finishes the chunk. Template lives in `AGENT_PRIMER.md §4`.

**Date completed:** _YYYY-MM-DD_
**Time spent:** _~Nh_

**Intended primary topic:** [T5] Context Management & Reliability
**Actually exercised:**
  - [T5] Context Management & Reliability — _<one line: what specifically did you do that practiced this — e.g., the JSONB raw_blob design, the bbox column choice, the confidence-numeric calibration column>_

**Surprise lesson (one line):**
_<the single thing you didn't know at the start of the chunk that you do now — exam-relevant only>_

**Drift check:**
  - Did this chunk drift into a topic the header said we wouldn't practice? [Y/N]
  - If yes: _<one line>_

**Cross-ref:** CCF_A_MAPPING.md §4 row 1.3
