# ADR-0009: Day 1 deliverable is the ontology Postgres DDL

**Date:** 2026-05-16
**Status:** Accepted

## Context

Week 1 of the AEGIS plan calls for four candidate Day-1 deliverables: ontology schema, synthetic corpus generation plan, demo storyboard, or a full living spec doc. We need to pick one to anchor the build, since the project depends on every later component (extraction, reconciliation, ratios, memo) binding to the ontology.

## Decision

Day 1 is the ontology — a Postgres DDL covering Borrower → Entity → FinancialPeriod → TaxReturn / BankStatement → LineItem → Ratio → Reconciliation → ExceptionFlag → Memo, plus the provenance columns (file, page, bbox, model, confidence) that every fact in the system carries.

## Alternatives considered

- **Synthetic corpus first.** Rejected: corpus shape is dictated by the ontology, not the other way round. If we generate corpus first, we either over-fit synthesis to a half-specified schema or have to re-generate later.
- **Demo storyboard first.** Rejected: useful exercise, but doesn't unblock any code. Defer to Week 1 Day 2 or 3.
- **Full living spec first.** Already partially done — the handover brief plus `PROJECT_SPEC.md` cover this. No reason to spend Day 1 prose-massaging instead of producing a load-bearing artifact.

## Consequences

- **Positive:** Every later module has a stable contract to bind to. Reconciliation can be designed in terms of ontology rows rather than ad-hoc dicts. The memo template can reference ontology tables directly.
- **Positive:** Forces us to make the *evidence model* decisions (provenance columns, JSONB for raw blobs) up-front, which is where most underwriting-AI projects get tangled later.
- **Negative / tradeoffs:** We commit to relational early. If we discover Phase 2 needs a richer evidence model than JSONB cleanly handles, we'll migrate. That's acceptable risk.
- **Follow-ups:** Day 2 = OCC memo-template study (Phase 4 input). Day 3 = synthetic persona spec.
