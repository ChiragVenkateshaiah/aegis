# Week 1 — Phase 1 (Foundation)

> **Phase goal:** Lock the data model, build domain understanding, seed the synthetic corpus.
> **Time budget:** 5 evening blocks (≈ 2–3h each) + 1 weekend block (≈ 4h).

---

## Day 1 — Ontology Postgres DDL  ← **START HERE**

**Spec sections:** §6 (component 3), §8
**Prompt:** [`docs/prompts/day-01-ontology-schema.md`](docs/prompts/day-01-ontology-schema.md)
**Mode in Claude Code CLI:** `/plan` first, then execute
**Estimated time:** ~3h
**Acceptance check:** DDL applies cleanly to a fresh Postgres 16 container; tables, FKs, indexes, and JSONB provenance columns all present; one round-trip insert/select smoke test passes.

**Output artifacts expected in the repo:**
- `data/schemas/ontology.sql` — full DDL
- `data/schemas/erd.md` — text ERD + table-by-table notes
- `data/seeds/seed_minimal.sql` — one fake borrower end-to-end
- `src/aegis/ontology/__init__.py` — package stub (no ORM yet)
- `docs/adr/0011-ontology-design-choices.md` — written *after* the chunk, capturing tradeoffs Claude Code CLI made

---

## Day 2 — Real credit memo template study

**Spec sections:** §6 (component 6)
**Mode:** Reading + note-taking. No code.
**Deliverable:** `docs/reference/credit-memo-template-notes.md` summarizing one OCC/RMA template — sections, required fields, citation patterns. This becomes the skeleton for the memo generator in Phase 4.

---

## Day 3 — Synthetic borrower persona spec

**Spec sections:** §7
**Mode:** Cowork drafts the persona spec; Claude Code CLI implements the persona JSON schema only (no generation yet).
**Deliverables:**
- `data/synthetic/borrowers/PERSONA_SPEC.md` — verticals (services / retail / restaurant), revenue bands, messiness traits, owner-draw patterns
- `data/schemas/persona.schema.json` — JSON schema for a persona
- 3 hand-written example personas, validated against schema

---

## Day 4 — Ittelson reading checkpoint + memo-template ↔ ontology mapping

**Mode:** Reading + mapping. Light writing.
**Deliverables:**
- 1-page memo: which Ittelson concepts map to which ontology tables
- Append open questions to `PROJECT_SPEC.md §11`

---

## Day 5 — Smoke-test corpus (3 borrowers end-to-end)

**Spec sections:** §7
**Mode:** Claude Code CLI `/plan` then execute.
**Deliverables:**
- `data/synthetic/borrowers/{001,002,003}/` each containing: persona.json, tax_return.pdf (LLM-generated), bank_statements.pdf
- The PDFs are openable, internally consistent, and contain at least one *intentional* discrepancy to validate Phase 3 later.

---

## Weekend block — Phase 1 closeout

- Verify all Phase 1 rows in `PHASES.md` are ✅
- Write phase-1 milestone entry in `DECISIONS.md`
- Tag the repo `phase-1-complete`
- Cowork drafts the first Phase 2 prompt
