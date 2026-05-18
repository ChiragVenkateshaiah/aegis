# AGENT_PRIMER.md — Read this first, every session

> **Who reads this:** every Cowork session and every Claude Code CLI session that touches AEGIS.
> **Why:** AEGIS is a dual-purpose build — an FDE portfolio piece *and* deliberate practice for the **CCF-A** (Claude Certified Foundations — Architect) exam. The primer makes that second purpose visible at the top of every chunk so practice is intentional, not accidental.
>
> **If you only have 60 seconds:** read §1 and §2 and stop.

**Last updated:** 2026-05-16

---

## 1. The 60-second briefing

AEGIS is an AI credit-memo co-pilot for SME lending — an 8-week build documented in [PROJECT_SPEC.md](PROJECT_SPEC.md) and phased in [PHASES.md](PHASES.md). On top of that, the build is engineered so each chunk also practices one or more CCF-A exam topics. The exam weights are:

| ID | Topic | Weight |
|----|---|---:|
| T1 | Agentic Architecture & Orchestration | 27% |
| T2 | Claude Code Configuration & Workflows | 20% |
| T3 | Prompt Engineering & Structured Output | 20% |
| T4 | Tool Design & MCP Integration | 18% |
| T5 | Context Management & Reliability | 15% |

The mapping from deliverables → topics lives in [CCF_A_MAPPING.md](CCF_A_MAPPING.md); the coverage table there hits each weight within ±1%.

**The rule:** every Day prompt in `docs/prompts/` opens with a **CCF-A Practice Header** (see §3). Every chunk closes with a **Practice Recap** (see §4). No exceptions, even on small chunks — for those we use the **compressed header** (§3.b).

---

## 2. The four rules

1. **Read this primer first.** Cowork or Claude Code, every session.
2. **Print the Practice Header at the top of every chunk.** It names the primary topic, secondary topics, and what's deliberately *not* being practiced.
3. **Log the Practice Recap when the chunk finishes.** One line per topic actually exercised + one surprise lesson.
4. **Don't invent new CCF-A deliverables on the fly.** The coverage table in [CCF_A_MAPPING.md](CCF_A_MAPPING.md) is balanced; new practice items go through an ADR.

---

## 3. The CCF-A Practice Header

### 3.a Full header (use for any chunk ≥ 1 hour or that introduces a new module)

Paste this block at the top of the chunk's prompt body. Fill in the brackets.

```text
═══════════════ CCF-A PRACTICE HEADER ═══════════════
Chunk:        Day NN — <slug>
Phase:        <N — phase name>

PRIMARY topic practiced this chunk:
  [Tx] <topic name> (<exam weight>%)
  Why this chunk: <one sentence on why the deliverable exercises this topic>

SECONDARY topics touched (lighter practice):
  [Ty] <topic name> (<weight>%) — <one phrase>
  [Tz] <topic name> (<weight>%) — <one phrase>     # omit row if none

DELIBERATELY NOT PRACTICED HERE (do not chase):
  [Ta] <topic name> — <one-phrase reason>
  [Tb] <topic name> — <one-phrase reason>
  [Tc] <topic name> — <one-phrase reason>
  # list every topic not named above as primary/secondary

CCF-A coverage cross-ref: CCF_A_MAPPING.md §4 row <#>
═══════════════════════════════════════════════════════
```

### 3.b Compressed header (use for short Sonnet chunks — error fixing, quick refactors, doc edits, <30 min)

```text
[CCF-A] Practicing: [Tx] <topic name>. Not practicing: [Ty,Tz,Ta,Tb]. Ref: CCF_A_MAPPING.md §4 row <#>.
```

A single line. If the chunk is so small that even this is friction, the chunk probably shouldn't be a tracked Day prompt — fold it into the next one.

### 3.c When the chunk is genuinely zero-CCF-A (e.g., reading Ittelson, recording the demo video)

```text
[CCF-A] No primary topic this chunk (domain/portfolio work). Ref: CCF_A_MAPPING.md §4.
```

Honesty beats stretching a tag.

---

## 4. The Practice Recap

After Claude Code (or Cowork) finishes the chunk, append a short recap at the *bottom* of the same `docs/prompts/day-NN-*.md` file under a `## Practice Recap` heading.

Template:

```markdown
## Practice Recap — Day NN

**Date completed:** YYYY-MM-DD
**Time spent:** ~Nh

**Intended primary topic:** [Tx] <topic name>
**Actually exercised:**
  - [Tx] <topic name> — <one line: what specifically did you do that practiced this>
  - [Ty] <topic name> — <if a secondary topic ended up getting real practice>

**Surprise lesson (one line):**
<the single thing you didn't know at the start of the chunk that you do now — exam-relevant only>

**Drift check:**
  - Did this chunk drift into a topic the header said we wouldn't practice? [Y/N]
  - If yes: <one line on what happened — usually fine, but worth noticing>

**Cross-ref:** CCF_A_MAPPING.md §4 row <#>
```

The recaps roll up into the pre-exam study log. Don't skip them — a missing recap is what makes you re-do work in week 7.

---

## 5. Worked example — Day 1 header

This is what Day 1's header looks like in practice (and what [`docs/prompts/day-01-ontology-schema.md`](docs/prompts/day-01-ontology-schema.md) prepends):

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
```

Note the structure: one primary, zero secondaries, and **every other topic is explicitly listed as "do not chase"**. That's the point — the header gives Cowork and Claude Code permission to ignore four of the five exam topics on this chunk so the lesson stays clean.

---

## 6. Model selection inside Cowork

Same rule as [WORKFLOW.md](WORKFLOW.md) §"When to use Opus vs. Sonnet". CCF-A practice doesn't change it. Headers and recaps can be drafted in Sonnet; topic coverage *design* (the kind of work that produced [CCF_A_MAPPING.md](CCF_A_MAPPING.md)) is Opus.

---

## 7. When the primer is wrong

If during a chunk the deliverable starts exercising a different topic than the header named, **don't quietly rewrite the header**. Finish the chunk, write the Practice Recap honestly (noting the drift), and bring it to the next planning session. Drift is data; covering it up is how the coverage math goes stale.

If the drift is intentional (a real re-scoping), open an ADR (`docs/adr/NNNN-slug.md`) and update [CCF_A_MAPPING.md](CCF_A_MAPPING.md) §4.
