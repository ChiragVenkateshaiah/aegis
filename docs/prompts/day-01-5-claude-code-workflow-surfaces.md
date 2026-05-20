# Day 01.5 — Wire up Claude Code workflow surfaces

**Phase:** 1 — Foundation
**Week:** 1
**Spec sections:** PROJECT_SPEC §1.1 (dual purpose), WORKFLOW.md (entire), AGENT_PRIMER.md §3–§4, CCF_A_MAPPING.md §4 rows 1.7 / 1.8 / 1.9
**Estimated time:** ~1.5–2h
**Mode in Claude Code CLI:** `/model opus` → `/plan` → review/accept → `/model sonnet` → execute. The chunk introduces a new module (`.claude/` configuration tree) across multiple files with reversibility cost. Plan mode mandatory.

---

## Paste-this prompt for Claude Code CLI

> Open Claude Code CLI inside the `aegis/` repo, run `/model opus`, then `/plan`, then paste everything inside the fenced block below. Review the plan, push back where needed, and accept. After the plan is accepted, run `/model sonnet` and let it execute. Stop and ask before any decision that's not explicitly answered here.

```text
═══════════════ CCF-A PRACTICE HEADER ═══════════════
Chunk:        Day 01.5 — Wire up Claude Code workflow surfaces
Phase:        1 — Foundation

PRIMARY topic practiced this chunk:
  [T2] Claude Code Configuration & Workflows (20%)
  Why this chunk: Three Claude Code configuration surfaces land here —
  CLAUDE.md at repo root (project memory), three custom slash commands,
  and two hooks. From this chunk forward, every Claude Code session in
  this repo inherits AEGIS conventions automatically, slash commands
  launch chunks with one keystroke, and hooks enforce the practice
  discipline (session-start reminder + schema-modified reminder).
  Banks 13pp of T2 in one chunk. T2 was at 0/20 before this.

SECONDARY topics touched (lighter practice):
  — (none — keep the focus on T2)

DELIBERATELY NOT PRACTICED HERE (do not chase):
  [T1] Agentic Architecture & Orchestration — no agents or orchestrators
  [T3] Prompt Engineering & Structured Output — no LLM prompts/schemas authored
  [T4] Tool Design & MCP Integration — MCP servers start in Phase 2
  [T5] Context Management & Reliability — schema/reliability landed in Day 1

CCF-A coverage cross-ref: CCF_A_MAPPING.md §4 rows 1.7, 1.8, 1.9
═══════════════════════════════════════════════════════

You are working inside the AEGIS repository — an AI credit-memo co-pilot for SME lending and a dual-purpose build (FDE portfolio + CCF-A exam practice). Read AGENT_PRIMER.md first (it explains the header above), then PROJECT_SPEC.md §1.1, PHASES.md (Phase 1 rows 1.7/1.8/1.9), WORKFLOW.md §"Model selection" + §"Standard prompt template", CCF_A_MAPPING.md §4 Phase 1 table, and DECISIONS.md before doing anything else.

## Goal
Stand up three Claude Code configuration surfaces so every subsequent chunk in this 8-week build inherits them. After this chunk: (a) opening Claude Code in this repo auto-loads AEGIS conventions, (b) `/aegis-plan <slug>` launches a chunk with one keystroke, (c) hooks enforce the practice discipline. This chunk is config-only — no Python, no schema changes, no MCP scaffolding.

## Required deliverables

### 1. `CLAUDE.md` at repo root (project memory)
The file Claude Code reads at session start. Include, in this order, under 200 lines total:
- First line (literal): "**ALWAYS read AGENT_PRIMER.md before reading anything else in this repo.**"
- One-paragraph project summary: AEGIS is an AI credit-memo co-pilot for SME lending, 8-week build, dual-purpose (portfolio + CCF-A practice). Status: Phase 1 Week 1, Day 1 ontology shipped.
- File map: which docs live at repo root (Cowork-maintained), what's in data/, src/aegis/, evals/, docs/{adr,prompts,reference,posts}, .claude/.
- Conventions: Python 3.11+, snake_case, plural table names, JSONB for evidence blobs, every fact-bearing row carries inline provenance (source_document_id, page_number, bbox, extractor_model, confidence, raw_blob). Refer to ADR-0011 for the why.
- Model selection: one-line cross-reference to WORKFLOW.md §"Model selection". Opus for /plan and architectural choices, Sonnet for execution.
- Workflow rule: "Cowork plans, Claude Code executes." Code edits land in src/, evals/, data/. Files at repo root are Cowork-maintained; do not edit without explicit instruction.
- CCF-A practice rule: every Day chunk opens with a Practice Header (AGENT_PRIMER.md §3) and closes with a Practice Recap (§4). The mapping ledger is CCF_A_MAPPING.md.
- Common commands block: `make schema-apply`, `make schema-verify`, the `docker exec aegis-pg psql` pattern.
- "Don't touch" list: docs/reference/ is frozen, root-level *.md files are Cowork-maintained, ADRs are append-only.

Keep it tight. CLAUDE.md gets reloaded constantly — every line costs context budget.

### 2. Three custom slash commands in `.claude/commands/`
Each is a markdown file whose body becomes the prompt expansion when the user types the slash command. Implement exactly three:

- `.claude/commands/aegis-plan.md`
  Reads AGENT_PRIMER.md, then reads `docs/prompts/$ARGUMENTS` (treat `$ARGUMENTS` as the day-slug — e.g., `day-02-credit-memo-template`), enters /plan mode, produces a plan that explicitly respects the CCF-A Practice Header at the top of the chunk file.
- `.claude/commands/aegis-status.md`
  Prints the current PHASES.md row statuses scoped to the active phase, lists any docs/prompts/day-*.md files with an unfilled Practice Recap (heuristic: contains `_<` placeholder syntax under the Practice Recap heading), and shows the running CCF-A coverage tally.
- `.claude/commands/aegis-recap.md`
  Helps fill the Practice Recap at the bottom of `docs/prompts/$ARGUMENTS` using the AGENT_PRIMER.md §4 template. Derives "actually exercised" from the chunk's deliverable list and the diff since the chunk started. Asks the user a single question — the surprise lesson — and leaves everything else inferred.

Note: CCF_A_MAPPING.md row 1.8 originally listed `/aegis-extract` and `/aegis-recon` as illustrative names. Replace with `/aegis-status` and `/aegis-recap` — those are useful now; extract/recon land in Phase 2/3 alongside their target modules. Update CCF_A_MAPPING.md row 1.8 wording accordingly (single-line description change).

### 3. Two hooks in `.claude/settings.json` (or the hooks file Claude Code looks for in the installed version — confirm and document the choice)
- **SessionStart**: print one short line — "AEGIS — read AGENT_PRIMER.md first. CCF_A_MAPPING.md is the topic ledger."
- **PostToolUse** scoped to Edit/Write where the path matches `data/schemas/*.sql` or `data/seeds/*.sql`: print one short reminder — "Schema or seed modified. Re-run `make schema-verify` against the aegis-pg container before declaring done."

Two hooks. Not three. Don't add a "would be cool" third hook.

### 4. ADR-0013 — `docs/adr/0013-claude-code-workflow-surfaces.md` (written AFTER the chunk)
Cover, in this order:
- Decision: project memory at repo root + 3 slash commands + 2 hooks.
- Why these three slash commands now (and not /aegis-extract or /aegis-recon yet): the chosen three exercise the workflow itself; the deferred two will land alongside their target modules in Phase 2/3.
- Why these two hooks (and not five): minimum that enforces practice discipline without nagging.
- Which hook config file was used (`.claude/settings.json` vs `.claude/hooks.json`) and why.
- What's intentionally NOT modeled in v1: subagent-specific hooks (Phase 3 work), MCP-server registration in `.claude/mcp.json` (Phase 2 work), eval-log PostToolUse hook (Phase 5 work).

### 5. Edit CCF_A_MAPPING.md §4 Phase 1 table
Update row 1.8 to reflect the actual command set: `/aegis-plan`, `/aegis-status`, `/aegis-recap`. Keep the points unchanged (4 pts T2). One-line edit.

### 6. Append a row to DECISIONS.md
ADR-0013, dated 2026-05-19, Accepted, one-line rationale linking to docs/adr/0013-claude-code-workflow-surfaces.md.

## Constraints
- CLAUDE.md under 200 lines.
- Each slash command body under 50 lines.
- Hooks: exactly two, scoped narrowly.
- No new Python code, no schema changes, no MCP scaffolding.
- Don't pre-create empty .claude/agents/ or .claude/mcp.json files — those land in Phase 2/3 with their targets.

## Acceptance check
After implementation, in a fresh Claude Code session opened against this repo:
1. SessionStart hook fires, prints the one-line reminder.
2. `/aegis-status` runs and prints the current Phase 1 status (1.3 ✅, others ☐).
3. Touch a file under data/schemas/ (then revert) → PostToolUse hook fires and prints the schema-modified reminder.
4. `/aegis-plan day-02-credit-memo-template` — the target file doesn't exist yet, so the command should attempt to read it and give a clear "file not found" message (validates the command parses $ARGUMENTS correctly).

All four pass = done.

## Open questions — pause and ask before deciding
- The hook configuration syntax differs across Claude Code versions. If both `.claude/hooks.json` and `.claude/settings.json` shapes are valid in the installed version, default to `.claude/settings.json`. If unsure which version is installed, ask the operator.
- The `$ARGUMENTS` placeholder for slash commands: confirm whether the installed Claude Code uses `$ARGUMENTS`, `{{arguments}}`, or another shape, before writing the command bodies. Don't guess.
- Should `/aegis-status` also print the running CCF-A coverage tally (a derived view of CCF_A_MAPPING.md §5), or just PHASES status? Default to including the tally — it's the one piece of info the operator can't easily eyeball.

## When you're done
1. Print a file-summary diff of everything created.
2. Print the output of `/aegis-status` from a test invocation.
3. Show ADR-0013's "intentionally NOT modeled" section.
4. Flip PHASES rows 1.7 / 1.8 / 1.9 to ✅ in PHASES.md.
5. STOP. Do not advance to Day 2. The next prompt comes from Cowork.
```

---

## Operator checklist (back in Cowork after Claude Code CLI finishes)

- [ ] Verify PHASES rows 1.7 / 1.8 / 1.9 flipped to ✅.
- [ ] Verify CCF_A_MAPPING.md §4 row 1.8 wording matches the actual command set.
- [ ] Read `docs/adr/0013-claude-code-workflow-surfaces.md`.
- [ ] Confirm `.claude/` tree is committed and a fresh Claude Code session loads CLAUDE.md.
- [ ] Fill in the Practice Recap below (operator-edited, not Claude-Code-edited — surprise lesson must be your own).
- [ ] Draft `docs/prompts/day-02-credit-memo-template.md` (Cowork, Sonnet).

---

## Practice Recap — Day 01.5

**Date completed:** 2026-05-20
**Time spent:** ~1.5h

**Intended primary topic:** [T2] Claude Code Configuration & Workflows
**Actually exercised:**
  - [T2] Claude Code Configuration & Workflows — wired `CLAUDE.md` as session-start project memory; authored three slash commands (`/aegis-plan`, `/aegis-status`, `/aegis-recap`) using `$ARGUMENTS` expansion under `.claude/commands/`; configured a `SessionStart` hook (AGENT_PRIMER.md reminder) and a `PostToolUse` hook scoped to `data/schemas/*.sql` and `data/seeds/*.sql` (schema-modified reminder) in `.claude/settings.json`; updated `CCF_A_MAPPING.md` rows 1.8/1.9 and flipped 1.7/1.8/1.9 to ✅; wrote ADR-0013.

**Surprise lesson (one line):**
PostToolUse hooks fire automatically after every matching Edit/Write tool call and surface verification output directly into Claude's session context — the hook runs the check so the developer never has to remember to.

**Drift check:**
  - Did this chunk drift into a topic the header said we wouldn't practice? N

**Cross-ref:** CCF_A_MAPPING.md §4 rows 1.7 / 1.8 / 1.9
