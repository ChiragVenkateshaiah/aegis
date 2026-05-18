# AEGIS — Development Workflow

> This is the historical record of *how* AEGIS was built. We're documenting the process intentionally so the case study can reference it and so future-Chirag can replicate the workflow on the next project.

---

## Session-start rules (read these first, every session)

These two rules apply to **every Cowork session** and **every Claude Code CLI session** that touches AEGIS. They exist because the build doubles as deliberate practice for the **CCF-A** exam — see [AGENT_PRIMER.md](AGENT_PRIMER.md) and [CCF_A_MAPPING.md](CCF_A_MAPPING.md).

1. **Every session reads [AGENT_PRIMER.md](AGENT_PRIMER.md) first**, before reading PROJECT_SPEC, PHASES, or any prompt. The primer is short and tells you what CCF-A topics this build practices and how to header/recap each chunk. If a session skips the primer, the practice tagging drifts and the coverage math goes stale.
2. **Every Day prompt in `docs/prompts/` includes a CCF-A Practice Header** at the top of its paste-this body (full form for chunks ≥ 1 hour, compressed form for short Sonnet chunks). The header names the *primary* topic, any *secondary* topics, and explicitly lists the topics **deliberately not practiced** in this chunk. The recap goes at the bottom of the same file after the chunk finishes. The template lives in [AGENT_PRIMER.md](AGENT_PRIMER.md) §3–§4.

---

## The two-tool loop

We use two Claude surfaces in tandem:

| Surface | Role | When |
|---|---|---|
| **Cowork (this app)** | **Planning + documentation.** Maintains living spec, phases, decision log, and **generates the prompts** that get pasted into Claude Code CLI. Uses Sonnet for routine drafting and **Opus for planning the harder chunks**. | Whenever direction is set, a phase milestone is reached, or a new prompt needs to be authored. |
| **Claude Code CLI** | **Execution inside the repo.** Writes code, runs tests, edits files, commits. Drops into **plan mode** for non-trivial chunks before writing any code. | Whenever code or schema needs to be produced or modified. |

**Rule:** Cowork never writes production code directly. Cowork writes the prompt that Claude Code CLI executes. This keeps every code change traceable to a versioned prompt in `docs/prompts/`.

---

## Prompt taxonomy

We work in three nested scopes:

```
Phase (1 of 5)
└── Week (1 of 8)
    └── Day / Chunk (one Claude Code CLI session)
```

A **Day / Chunk prompt** is the unit Claude Code CLI consumes. Each one is:

- Scoped to ≤ ~2–3 hours of work
- Saved as `docs/prompts/day-NN-slug.md` *before* execution
- Has a clear *acceptance check* (so we know when the chunk is done)
- References the PROJECT_SPEC section it implements

We start a **new Claude Code session per chunk** to keep context clean. The prompt itself carries any context Claude Code needs.

---

## Standard prompt template

Every Day prompt in `docs/prompts/` follows this shape:

```markdown
# Day NN — <slug>

**Phase:** N — <phase name>
**Week:** N
**Spec sections:** PROJECT_SPEC §X.Y, §X.Z
**Estimated time:** ~Nh
**Mode:** /plan first, then execute    (or: direct execute)

## Paste-this prompt for Claude Code CLI

<CCF-A Practice Header — see AGENT_PRIMER.md §3 for the full block. Required at the top of every chunk body. Compressed form for chunks under ~30 min.>

## Context
<2–4 paragraphs of background — what we have, what's missing, why this matters now>

## Inputs (read first)
- AGENT_PRIMER.md  ← always first
- file: path/to/something.md
- ADR: docs/adr/NNNN-slug.md
- reference: docs/reference/<file>

## Deliverables
- [ ] file: path/to/output1
- [ ] file: path/to/output2
- [ ] passing check: <how we verify>

## Constraints
- Use <stack choice>
- Don't touch <out-of-scope area>
- Conform to <style/convention>

## Acceptance check
A short, testable description: "Running `make schema-apply` on a fresh Postgres 16 container applies the DDL with zero errors and exactly N tables exist."

## Open questions for the operator
- Anything Claude Code should pause and ask before deciding

## Practice Recap — Day NN
<filled in after the chunk finishes; template in AGENT_PRIMER.md §4>
```

---

## End-of-chunk protocol

After Claude Code CLI finishes a chunk, **come back to Cowork** and:

1. Update the relevant row in `PHASES.md` (status flip to ✅).
2. Append any new decisions to `DECISIONS.md` (and write the ADR if it's non-trivial).
3. If the chunk uncovered open questions or follow-ups, add them to `PROJECT_SPEC.md §11` or queue them as the next Day's chunk.
4. Cowork drafts the next Day prompt in `docs/prompts/day-NN+1-slug.md`.

---

## End-of-phase protocol

When all rows in a phase flip to ✅:

1. Record a **phase milestone** entry in `DECISIONS.md` summarizing what shipped, what the eval numbers were (if applicable), and what the surprise lessons were.
2. Tag the repo: `phase-N-complete`.
3. Re-read PROJECT_SPEC and prune anything stale.
4. Draft the next phase's prompts in `docs/prompts/`.

---

## When to use Opus vs. Sonnet (in Cowork)

| Use Opus | Use Sonnet |
|---|---|
| Designing the ontology schema | Drafting a status update |
| Designing the eval rubric | Writing a per-field extractor prompt |
| Trade-off analysis for the reconciliation engine | Renaming files, reformatting docs |
| Case-study narrative draft | Maintaining the phase tracker |
| Phase planning / replan after a missed milestone | Generating routine Day chunk prompts |

When in doubt, default to Sonnet for execution and lean on Opus for **design + tradeoffs + writing about the project**.

---

## When Claude Code CLI should enter `/plan` mode

- The chunk touches more than ~3 files
- The chunk introduces a new module or schema
- The chunk has reversibility cost (DB migrations, public API shapes)
- The acceptance check has more than one criterion

Otherwise direct-execute is fine.

---

## Living docs we maintain

| File | Maintained by | Cadence |
|---|---|---|
| `AGENT_PRIMER.md` | Cowork | When practice rules change (rare) |
| `CCF_A_MAPPING.md` | Cowork | When a new deliverable is added or re-tagged (via ADR) |
| `PROJECT_SPEC.md` | Cowork | When direction changes |
| `PHASES.md` | Cowork | After every chunk |
| `DECISIONS.md` (+ `docs/adr/`) | Cowork | When a decision is made |
| `WEEK_NN_TASKS.md` | Cowork | Start + end of each week |
| `docs/prompts/day-NN-*.md` | Cowork (frozen once Claude Code CLI starts) | Before each chunk |
| Code under `src/` | Claude Code CLI | Continuous |
| `evals/results/` | Claude Code CLI | End of phases 2, 3, 5 |
