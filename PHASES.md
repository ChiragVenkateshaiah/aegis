# AEGIS — Phased Plan

> 8-week plan. Evenings + weekends. Update status as we go. Each phase ends with a **milestone commit** to the decision log.
>
> The **CCF-A** column tags each deliverable with the primary CCF-A topic it practices (and secondary if applicable). See [CCF_A_MAPPING.md](CCF_A_MAPPING.md) for the full mapping, and [AGENT_PRIMER.md](AGENT_PRIMER.md) for the per-chunk Practice Header that operationalizes it.

**Legend:** ☐ not started · ◐ in progress · ✅ done · ✖ skipped
**CCF-A topic codes:** T1 Agentic Arch (27%) · T2 Claude Code (20%) · T3 Prompts/Structured Output (20%) · T4 Tools/MCP (18%) · T5 Context/Reliability (15%) · — none

---

## Phase 1 — Foundation (Week 1)

**Goal:** Lock the data model, understand the domain, generate the synthetic corpus seed, *and* establish the Claude Code workflow surfaces (CLAUDE.md, slash commands, hooks) that the rest of the build will use.
**Status:** ◐ in progress (Day 1 ✅ · Day 01.5 ✅ · Day 2 ✅ · Day 3 ✅ complete — Day 4 next: Ittelson checkpoint + memo-template ↔ ontology mapping)

| # | Deliverable | CCF-A | Status | Notes |
|---|---|---|---|---|
| 1.1 | Read first half of Ittelson (Chapters 1–8) | — | ☐ | Evenings |
| 1.2 | Study a real credit memo template (OCC) | — | ✅ | **Day 2 complete 2026-05-21 — 14-section OCC breakdown, 25-term glossary, 7 ontology gaps logged** |
| 1.3 | **Ontology schema — Postgres DDL** | **T5** | ✅ | **Day 1 complete 2026-05-19 — DDL + seed + check.sh all-green** |
| 1.4 | Synthetic borrower persona spec (30–50 personas) | T3 | ✅ | **Day 3 complete 2026-05-29 — PERSONA_SPEC.md, persona.schema.json, 3 validated examples** |
| 1.5 | Generate v0 synthetic corpus (3 borrowers end-to-end as smoke test) | T3 | ☐ | end of week |
| 1.6 | Lock data dictionary (per ontology table) | — | ☐ | derives from 1.3 |
| **1.7** | **`CLAUDE.md` at repo root** (memory file) | **T2** | ✅ | **shipped 2026-05-19** — project conventions, file map, model preferences, the "read AGENT_PRIMER.md first" rule |
| **1.8** | **Custom slash commands** (`/aegis-plan`, `/aegis-status`, `/aegis-recap`) | **T2** | ✅ | **shipped 2026-05-19** — chunk launchers wired into the workflow; `/aegis-extract` and `/aegis-recon` deferred to Phase 2/3 |
| **1.9** | **Hooks** (SessionStart reminder, PostToolUse schema-modified reminder) | **T2** | ✅ | **shipped 2026-05-19** — two hooks in `.claude/settings.json`; reminder injected into Claude's context via JSON additionalContext |

**Phase exit criteria:**
- Ontology DDL applies cleanly to a fresh Postgres instance, with seed data.
- Data dictionary published.
- 3-borrower smoke corpus generated and inspectable.
- ADRs recorded for ontology design + data strategy.
- `CLAUDE.md`, slash commands, and hooks committed and exercised on at least one real chunk.

---

## Phase 2 — Extraction (Weeks 2–3)

**Goal:** PDF → structured ontology rows, with confidence scores. Hit ≥ 90% field accuracy on a small hold-out before exiting. **Phase 2 also stands up `aegis-ontology-mcp`** — the first of two MCP servers in the build.
**Status:** ☐

| # | Deliverable | CCF-A | Status | Notes |
|---|---|---|---|---|
| 2.1 | Ingestion pipeline (PDF intake + page rendering) | — | ☐ | |
| 2.2 | Tax-return extractor (1120 / 1120S / 1065) | T3 | ☐ | Claude vision primary |
| 2.3 | Bank-statement extractor (transactions + summary) | T3 | ☐ | |
| 2.4 | Confidence-score schema + persistence | T5 | ☐ | |
| 2.5 | OCR fallback path | T1 | ☐ | vision → OCR → manual-flag routing (small orchestration pattern) |
| 2.6 | Mini eval: per-field accuracy on 10 borrowers | T5 | ☐ | gate to Phase 3 |
| **2.7** | **`aegis-ontology-mcp` server** — `query_ontology`, `write_line_items` tools | **T4** | ☐ | Deep T4 deliverable; first of 2 MCP servers in the build |
| **2.8** | **Subdirectory `CLAUDE.md/` memory files** (per `src/aegis/*` module) | **T2** | ☐ | Scoped context for Claude Code when working inside a module |

**Phase exit criteria:**
- ≥ 90% field-level extraction accuracy on the mini hold-out.
- All extracted facts land in the ontology with provenance (file + page + bbox).
- `aegis-ontology-mcp` registered with Claude Code and used in at least one chunk.

---

## Phase 3 — Reasoning (Weeks 4–5)  ← **showcase work**

**Goal:** Reconciliation engine + ratios. This is the differentiator — budget the time. **Phase 3 also lands the headline T1 exercise: a reconciliation orchestrator that dispatches three subagents in parallel.**
**Status:** ☐

| # | Deliverable | CCF-A | Status | Notes |
|---|---|---|---|---|
| 3.1 | Reconciliation check #1 — tax return revenue vs. bank deposits | — | ☐ | becomes a subagent under 3.7 |
| 3.2 | Reconciliation check #2 — declared owner draws vs. bank withdrawals | — | ☐ | subagent under 3.7 |
| 3.3 | Reconciliation check #3 — debt-to-income consistency | — | ☐ | subagent under 3.7 |
| 3.4 | Ratio engine (DSCR, current ratio, debt service, working capital, owner DTI) | T4 | ☐ | each ratio is a typed tool — non-MCP tool-design practice |
| 3.5 | Exception-flag schema + severity grading | T3 | ☐ | |
| 3.6 | Mid-phase eval: flag precision / recall | T5 | ☐ | |
| **3.7** | **Reconciliation orchestrator with parallel subagents** | **T1 (+T2)** | ☐ | Headline T1 deliverable. Orchestrator dispatches 3.1/3.2/3.3 in parallel via the Claude Code subagent primitive, merges results, ranks by severity, handles subagent failure |

**Phase exit criteria:**
- All 3 reconciliations produce structured ExceptionFlag rows with explanations.
- Ratios computed with thresholds and verdicts.
- Precision ≥ 85% on a small flagged-vs-truth set.
- The reconciliation orchestrator runs the three subagents in parallel (verified in trace logs).

---

## Phase 4 — Synthesis (Week 6)

**Goal:** Generate the memo + ship the analyst UI. **Phase 4 adds a memo composer agent and a citation subagent** — a clean two-agent pattern that doubles as T1 practice.
**Status:** ☐

| # | Deliverable | CCF-A | Status | Notes |
|---|---|---|---|---|
| 4.1 | Memo template (simplified OCC) | T3 | ☐ | |
| 4.2 | Citation engine (every claim → source page) | T5 | ☐ | ungrounded claims removed, not glossed |
| 4.3 | Memo generation pipeline | — | ☐ | plumbing over 4.1 / 4.5 |
| 4.4 | Streamlit UI — upload, ontology view, memo, flag panel | — | ☐ | |
| **4.5** | **Memo composer agent + citation subagent** | **T1 (+T2)** | ☐ | Composer drafts; citation subagent validates every claim; uses subagent primitive |

**Phase exit criteria:**
- End-to-end run: 2 PDFs → ontology populated → flags surfaced → memo drafted with citations.
- ≤ 8 min wall-clock on the demo machine.
- Composer + citation subagent traced end-to-end on at least 3 hold-out borrowers.

---

## Phase 5 — Measurement (Weeks 7–8)

**Goal:** Eval framework, benchmarks, demo video, case study. **Phase 5 also stands up `aegis-eval-mcp`** (the second MCP server) and **the LLM-as-judge agent** (the final T1 piece).
**Status:** ☐

| # | Deliverable | CCF-A | Status | Notes |
|---|---|---|---|---|
| 5.1 | Gold-standard set: 20–30 borrowers w/ analyst-graded memos | — | ☐ | |
| 5.2 | **Eval harness** (per-field acc, ratio acc, flag P/R, memo quality) | **T5** | ☐ | Deep T5 deliverable |
| 5.3 | LLM-as-judge for memo quality (rubric prompt) | T3 | ☐ | rubric + spot-check |
| 5.4 | Benchmark run + results table | — | ☐ | hit the targets in PROJECT_SPEC §9 |
| 5.5 | 60-second demo video | — | ☐ | |
| 5.6 | Case study writeup with ROI math | — | ☐ | |
| **5.7** | **`aegis-eval-mcp` server** — `run_eval`, `compare_runs`, `gate_regression` tools | **T4** | ☐ | Second of 2 MCP servers; surfaces the harness as MCP tools |
| **5.8** | **LLM-as-judge agent** | **T1** | ☐ | Orchestrates rubric runs across the gold set, aggregates scores, flags judge↔human disagreements |

**Phase exit criteria — and v1 ship criteria:**
- All metrics in PROJECT_SPEC §9 hit.
- Demo video recorded.
- Case study published (LinkedIn + portfolio site).
- Both MCP servers shipped; CCF-A study log (rolled-up Practice Recaps) ready for exam review.

---

## CCF-A coverage roll-up

Per-topic coverage across the phases (full math in [CCF_A_MAPPING.md](CCF_A_MAPPING.md) §5):

| Topic | Phase 1 | Phase 2 | Phase 3 | Phase 4 | Phase 5 | Total | Target |
|---|---:|---:|---:|---:|---:|---:|---:|
| T1 Agentic Arch | — | 3 | 12 | 8 | 4 | **27%** | 27% |
| T2 Claude Code | 13 | 3 | 2 | 2 | — | **20%** | 20% |
| T3 Prompts | 5 | 7 | 2 | 3 | 3 | **20%** | 20% |
| T4 Tools/MCP | — | 8 | 4 | — | 6 | **18%** | 18% |
| T5 Context/Reliability | 3 | 3 | 1 | 2 | 6 | **15%** | 15% |

The T2 values for Phases 3–4 are the secondary points contributed by the subagent-primitive usage in deliverables 3.7 and 4.5. All targets hit within ±0%.
