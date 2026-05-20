# AEGIS ↔ CCF-A Syllabus Mapping

> **Purpose.** AEGIS is a dual-purpose build:
> (1) an FDE-portfolio project (AI credit-memo co-pilot for SME lending, 8-week build), and
> (2) deliberate practice for Anthropic's **CCF-A** (Claude Certified Foundations — Architect) certification.
>
> This file is the master mapping: every CCF-A topic is tied to specific deliverables across the 5 phases, and the coverage table at the bottom shows the percentage each topic gets, calibrated to the exam weights within ±1%.

**Last updated:** 2026-05-16
**Owner:** Chirag
**Companion docs:** [AGENT_PRIMER.md](AGENT_PRIMER.md), [PHASES.md](PHASES.md), [docs/adr/0012-ccf-a-syllabus-mapping.md](docs/adr/0012-ccf-a-syllabus-mapping.md)

---

## 1. CCF-A topic weights (the target)

| ID | Topic | Exam weight |
|----|---|---:|
| T1 | Agentic Architecture & Orchestration | 27% |
| T2 | Claude Code Configuration & Workflows | 20% |
| T3 | Prompt Engineering & Structured Output | 20% |
| T4 | Tool Design & MCP Integration | 18% |
| T5 | Context Management & Reliability | 15% |
| | **Total** | **100%** |

The goal is for AEGIS's *practice surface area* — the deliverables that exercise each topic — to mirror these weights within ±1pp. That way, time spent building the portfolio piece doubles as exam-weighted study without us re-balancing later.

---

## 2. Design principles (anti-overengineering)

These constraints govern what counts as a CCF-A deliverable. They prevent the cert-prep angle from inflating the build.

1. **Two MCP servers total, not three.** `aegis-ontology-mcp` in Phase 2 and `aegis-eval-mcp` in Phase 5. Anything else gets cut.
2. **No custom agent framework.** All multi-agent work uses Claude Code's subagent primitive (or the Claude Agent SDK if a chunk runs outside Claude Code). We do not build our own orchestration layer.
3. **15%-weight topics get one *deep* deliverable, not five shallow ones.** T5 (Context Management & Reliability) is anchored in the eval harness; T4 (Tool Design & MCP) is anchored in the two MCP servers. Surrounding deliverables provide supporting practice, not duplication.
4. **No Next.js until Streamlit is shipping.** UI polish is a Phase 5 stretch, not a CCF-A surface.
5. **Practice has to be load-bearing for the product.** If a deliverable exists only to tick a topic box, it doesn't ship.

---

## 3. The new deliverables added for CCF-A coverage

These are the items that didn't exist in the original 8-week plan but earn their place by being load-bearing for the product *and* exercising under-represented topics.

| Tag | Deliverable | Phase | Primary topic |
|---|---|---|---|
| **1.7** | `CLAUDE.md` at repo root (memory file) | 1 | T2 |
| **1.8** | Custom slash commands (`/aegis-plan`, `/aegis-status`, `/aegis-recap`) | 1 | T2 |
| **1.9** | Hooks (SessionStart reminder; PostToolUse schema-modified reminder) | 1 | T2 |
| **2.7** | `aegis-ontology-mcp` server — ontology read/write tools surfaced to Claude Code | 2 | T4 |
| **2.8** | Subdirectory `CLAUDE.md/` memory files (per-module context) | 2 | T2 |
| **3.7** | Reconciliation orchestrator with **parallel subagents** (one per recon check) | 3 | T1 |
| **4.5** | Memo composer agent + citation subagent | 4 | T1 |
| **5.7** | `aegis-eval-mcp` server — eval harness exposed as MCP tools | 5 | T4 |
| **5.8** | LLM-as-judge agent (orchestrates the rubric runs) | 5 | T1 |

Each one is justified inline below in §4.

---

## 4. Phase-by-phase mapping

Each phase below lists every deliverable (existing + new), its primary CCF-A topic, secondary topics if applicable, and a one-line note explaining *why* this exercises that topic. Items with no CCF-A tag are domain/portfolio work that doesn't directly practice an exam topic — that's fine; coverage doesn't have to be total.

### Phase 1 — Foundation (Week 1)

| # | Deliverable | Primary | Secondary | Why |
|---|---|---|---|---|
| 1.1 | Read Ittelson chapters 1–8 | — | — | Domain knowledge; not CCF-A |
| 1.2 | OCC credit-memo template study | — | — | Domain knowledge; not CCF-A |
| 1.3 | **Ontology Postgres DDL with provenance columns** | **T5** | — | Every fact carries (document, page, bbox, model, confidence) — this *is* the reliability substrate the rest of the system depends on |
| 1.4 | Synthetic borrower persona spec (JSON schema) | T3 | — | Schema-constrained generation; designs the structured-output target for Day 5 |
| 1.5 | v0 synthetic corpus (3 borrowers, smoke test) | T3 | — | Prompt-engineered LLM synthesis with consistency checks |
| 1.6 | Data dictionary | — | — | Documentation; not CCF-A |
| **1.7** | **`CLAUDE.md` at repo root** | **T2** | — | The core Claude Code config primitive — project-level memory, conventions, file map |
| **1.8** | **Custom slash commands** (`/aegis-plan`, `/aegis-status`, `/aegis-recap`) | **T2** | — | Chunk launchers wired into the workflow. `/aegis-extract` and `/aegis-recon` deferred to Phase 2/3 alongside their target modules. |
| **1.9** | **Hooks** | **T2** | — | `SessionStart` AGENT_PRIMER.md reminder; `PostToolUse` schema-modified reminder injected into Claude's context — Claude Code hook surfaces in practice |

### Phase 2 — Extraction (Weeks 2–3)

| # | Deliverable | Primary | Secondary | Why |
|---|---|---|---|---|
| 2.1 | PDF ingestion pipeline | — | — | Plumbing; not CCF-A |
| 2.2 | Tax-return extractor (1120 / 1120S / 1065) | T3 | — | Vision-prompt + JSON-schema structured output — the canonical T3 exercise |
| 2.3 | Bank-statement extractor | T3 | — | Same pattern, harder OCR; transactions + summary structured output |
| 2.4 | Confidence-score schema + persistence | T5 | — | Per-field calibrated confidence is a reliability primitive |
| 2.5 | OCR fallback path | T1 | — | A fallback chain (vision → OCR → manual flag) is a baby agentic-orchestration pattern; we make the routing logic explicit |
| 2.6 | Mini eval (10 borrowers) — Phase 2 exit gate | T5 | — | Reliability gate: don't advance until ≥ 90% field accuracy |
| **2.7** | **`aegis-ontology-mcp` server** | **T4** | — | Two MCP tools: `query_ontology(borrower_id)` and `write_line_items(facts)` — the deep T4 deliverable; lets every later agent read/write the ontology through a typed tool surface |
| **2.8** | **Subdirectory `CLAUDE.md/` memory files** | **T2** | — | `src/aegis/extraction/CLAUDE.md`, `src/aegis/ontology/CLAUDE.md` etc. — scoped context that loads when Claude Code is working in that subtree |

### Phase 3 — Reasoning (Weeks 4–5) — showcase work

| # | Deliverable | Primary | Secondary | Why |
|---|---|---|---|---|
| 3.1 | Reconciliation check #1 — revenue vs. deposits | — | — | Becomes a subagent invocation under 3.7 |
| 3.2 | Reconciliation check #2 — declared draws vs. withdrawals | — | — | Subagent under 3.7 |
| 3.3 | Reconciliation check #3 — DTI consistency | — | — | Subagent under 3.7 |
| 3.4 | Ratio engine (DSCR, current, debt service, working capital, owner DTI) | T4 | — | Each ratio is a typed tool (input → ontology rows, output → ratio + threshold verdict); good T4 *non-MCP* tool-design practice |
| 3.5 | Exception-flag schema + severity grading | T3 | — | Structured-output schema for flag-bearing rows |
| 3.6 | Mid-phase eval — flag precision/recall | T5 | — | Reliability gate before memo work |
| **3.7** | **Reconciliation orchestrator with parallel subagents** | **T1** | T2 | The headline T1 exercise: one orchestrator agent dispatches three reconciliation subagents in parallel using Claude Code's subagent primitive, merges results, ranks by severity. Includes the design decision on parallel-vs-sequential and on how to handle subagent failure |

### Phase 4 — Synthesis (Week 6)

| # | Deliverable | Primary | Secondary | Why |
|---|---|---|---|---|
| 4.1 | Memo template (simplified OCC) | T3 | — | Prompt-design exercise: structuring an LLM narrative around a fixed template |
| 4.2 | Citation engine (every claim → source page) | T5 | — | Reliability primitive: ungrounded claims are *removed*, not glossed |
| 4.3 | Memo generation pipeline | — | — | Plumbing layer over 4.1/4.5 |
| 4.4 | Streamlit UI | — | — | UX work; not CCF-A |
| **4.5** | **Memo composer agent + citation subagent** | **T1** | T2 | Composer agent drafts; citation subagent validates every claim and either attaches a citation or strikes the claim — a clean two-agent pattern. Uses the subagent primitive |

### Phase 5 — Measurement (Weeks 7–8)

| # | Deliverable | Primary | Secondary | Why |
|---|---|---|---|---|
| 5.1 | Gold-standard set (20–30 borrowers) | — | — | Data work; not CCF-A |
| 5.2 | **Eval harness** | **T5** | — | **The deep T5 deliverable.** Per-field accuracy, ratio accuracy, flag P/R, end-to-end memo quality. Reproducible, versioned, gated on regression. |
| 5.3 | LLM-as-judge rubric prompt | T3 | — | Rubric-prompt design — a high-leverage T3 exercise |
| 5.4 | Benchmark run + results table | — | — | Executing the harness; not direct CCF-A |
| 5.5 | 60-second demo video | — | — | Portfolio; not CCF-A |
| 5.6 | Case-study writeup with ROI math | — | — | Portfolio; not CCF-A |
| **5.7** | **`aegis-eval-mcp` server** | **T4** | — | Exposes `run_eval(suite)`, `compare_runs(a, b)`, `gate_regression(threshold)` as MCP tools — completes the two-MCP-server budget |
| **5.8** | **LLM-as-judge agent** | **T1** | — | Orchestrates rubric runs across the gold set, aggregates scores, surfaces disagreements with the human spot-check |

---

## 5. Coverage table — points and percentages

Each deliverable contributes a point allocation to one or more topics. The points reflect the *depth* of practice the deliverable provides, not just whether it touches a topic. Totals are the percentage each topic gets in the AEGIS build.

| Topic | Deliverables (points) | Total | Target | Δ |
|---|---|---:|---:|---:|
| **T1** Agentic Architecture & Orchestration | 2.5 (3) · 3.7 (12) · 4.5 (8) · 5.8 (4) | **27%** | 27% | 0 |
| **T2** Claude Code Configuration & Workflows | 1.7 (5) · 1.8 (4) · 1.9 (4) · 2.8 (3) · 3.7 subagent (2) · 4.5 subagent (2) | **20%** | 20% | 0 |
| **T3** Prompt Engineering & Structured Output | 1.4 (2) · 1.5 (3) · 2.2 (4) · 2.3 (3) · 3.5 (2) · 4.1 (3) · 5.3 (3) | **20%** | 20% | 0 |
| **T4** Tool Design & MCP Integration | 2.7 (8) · 3.4 (4) · 5.7 (6) | **18%** | 18% | 0 |
| **T5** Context Management & Reliability | 1.3 (3) · 2.4 (2) · 2.6 (1) · 3.6 (1) · 4.2 (2) · 5.2 (6) | **15%** | 15% | 0 |
| | **Grand total** | **100%** | 100% | — |

All five topics hit their exam weight *exactly*. ±1% tolerance verified.

---

## 6. How to read this when you're building

Every Day prompt in `docs/prompts/` prepends a **CCF-A Practice Header** (see [AGENT_PRIMER.md](AGENT_PRIMER.md)) listing:

- The primary CCF-A topic for that chunk (with weight)
- Any secondary topics
- Which topics are **deliberately not practiced** in this chunk (so we don't dilute the lesson)

When you finish a chunk, you log a one-line **Practice Recap** noting what you actually exercised vs. what you intended. Over the 8 weeks, the recaps roll up into a study log you can review before the exam.

---

## 7. Status of new deliverables

| # | Deliverable | Status |
|---|---|---|
| 1.7 | `CLAUDE.md` at repo root | ✅ |
| 1.8 | Custom slash commands | ✅ |
| 1.9 | Hooks | ✅ |
| 2.7 | `aegis-ontology-mcp` server | ☐ |
| 2.8 | Subdirectory `CLAUDE.md/` memory files | ☐ |
| 3.7 | Reconciliation orchestrator + parallel subagents | ☐ |
| 4.5 | Memo composer agent + citation subagent | ☐ |
| 5.7 | `aegis-eval-mcp` server | ☐ |
| 5.8 | LLM-as-judge agent | ☐ |

Each gets a row in [PHASES.md](PHASES.md) so it's tracked alongside the original deliverables.
