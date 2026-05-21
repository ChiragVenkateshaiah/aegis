[CCF-A] No primary topic this chunk (domain/portfolio work). Ref: CCF_A_MAPPING.md §4 row 1.2.

# Day 02 — OCC Credit-Memo Template Study

**Phase:** 1 — Foundation
**Week:** 1
**Spec sections:** PROJECT_SPEC §6 (component 6)
**Mode:** Reading + note-taking. No code. No plan mode needed.
**Estimated time:** ~2–3h

## Goal

Study a real credit-memo template (OCC Comptroller's Handbook: Commercial Loans) and determine whether the Day 1 ontology correctly models all required fields. Produce: (a) a structured section-by-section breakdown of the OCC template, (b) a domain glossary, (c) a source access log, and (d) a parking-lot of ontology observations to revisit in a future iteration chunk.

## Actual output artifacts

- docs/study/day-02-occ-credit-memo-template.md — 14 credit-memo sections, each with what it contains, why it matters, and evidence sources
- docs/study/day-02-glossary.md — 25 terms with one-paragraph definitions and OCC source citations
- docs/study/day-02-source-log.md — access log for all 5 sources; notes that OCC PDFs are binary/not parseable by WebFetch; FDIC ch11.pdf returned 403; RMA is subscription-only
- docs/notes/day-02-observations.md — 7 ontology gap observations parked for a future iteration chunk; no action taken

## Deviation note

WEEK_01_TASKS.md originally specified docs/reference/credit-memo-template-notes.md as the deliverable path. Actual output went to docs/study/ because docs/reference/ is frozen per CLAUDE.md. WEEK_01_TASKS.md has been updated to reflect the actual paths.

---

## Practice Recap — Day 02

**Date completed:** 2026-05-21
**Time spent:** ~2–3h

**Intended primary topic:** None — domain/portfolio work (CCF-A row 1.2 carries "—")
**Actually exercised:**
  - [none] — No CCF-A topic was the primary target. Domain knowledge of SME credit underwriting was deepened: credit memo section structure (14 sections), UCA cash flow mechanics, interagency classification ladder (Pass → Special Mention → Substandard → Doubtful → Loss), covenant taxonomy (financial / reporting / affirmative / negative), collateral advance rates by type, and dual risk rating (BRR for PD, FRR for LGD). This feeds T3 and T1 indirectly in later phases but was not structured CCF-A practice.

**Surprise lesson (one line):**
Dual risk rating (BRR for PD, FRR for LGD) is not modeled in the Day 1 ontology — the current schema carries a single risk rating field, which will need to split into two dimensions before Phase 3 risk-rating logic can be correct.

**Drift check:**
  - Did this chunk drift into a topic the header said we wouldn't practice? N
  - If yes: n/a

**Cross-ref:** CCF_A_MAPPING.md §4 row 1.2
