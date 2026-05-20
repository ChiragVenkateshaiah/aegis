# ADR-0013: Claude Code Workflow Surfaces

**Date:** 2026-05-19
**Status:** Accepted

## Context

Phase 1 needs Claude Code to inherit AEGIS conventions across sessions (project memory), to launch chunk prompts with one keystroke (slash commands), and to enforce practice discipline without nagging (hooks). Before this chunk, T2 (Claude Code Configuration & Workflows, exam weight 20%) had 0/20 points banked. Day 01.5 banks all 13 Phase-1 T2 points in one config-only chunk.

Three configuration surfaces are available in Claude Code: project memory (CLAUDE.md), custom slash commands, and hooks. This ADR records the decisions around each.

## Decision

Ship three surfaces in one chunk:

1. **`CLAUDE.md` at repo root** — project memory loaded at every session start. Contains the mandatory AGENT_PRIMER.md read rule, project summary, file map, conventions, model selection cross-ref, workflow rule, CCF-A practice rule, common commands, and a "don't touch" list.

2. **Three slash commands** under `.claude/commands/`: `/aegis-plan`, `/aegis-status`, `/aegis-recap`. Each is a single `.md` file whose body becomes the prompt when the command is invoked.

3. **Two hooks** in `.claude/settings.json`: a `SessionStart` hook that prints the AGENT_PRIMER.md reminder, and a `PostToolUse` hook scoped to `Edit|Write` on `data/schemas/*.sql` and `data/seeds/*.sql` that injects a schema-verification reminder into Claude's context.

## Why these three slash commands now (not `/aegis-extract` or `/aegis-recon`)

The chosen three exercise the workflow itself:
- `/aegis-plan` — launches any chunk prompt with one keystroke; useful every day of the build from Day 02 forward.
- `/aegis-status` — gives an instant snapshot of Phase progress + unfilled recaps + CCF-A coverage; eliminates manual file-browsing during the Cowork handoff.
- `/aegis-recap` — closes every chunk by filling the Practice Recap; enforces the tagging discipline that keeps CCF_A_MAPPING.md accurate.

`/aegis-extract` and `/aegis-recon` were listed in the original CCF_A_MAPPING.md row 1.8 as illustrative names but they are premature: the extraction and reconciliation modules don't exist yet, and a command that helps run them has no target to point at. They land in Phase 2/3 alongside their modules. Premature slash commands that do nothing are ergonomic debt, not practice.

## Why these two hooks (not five)

Minimum that enforces practice discipline without nagging:

- `SessionStart` — ensures every session reads AGENT_PRIMER.md first without the operator having to remember. One line, zero friction.
- `PostToolUse` on schema/seed files — catches the highest-risk silent failure in the build: editing a schema file and forgetting to re-run `check.sh`. The reminder is injected into Claude's context (not just the user's transcript) because Claude is the entity writing the files.

Any additional hooks at this stage would be ergonomic debt:
- A pre-commit lint hook would block commits during rapid schema iteration — net negative in Week 1.
- A "test coverage" hook has no target until Phase 2 introduces real modules.
- An eval-log hook (Phase 5 work) is premature until the eval harness exists.

Three or more hooks now means reviewing and maintaining more hook logic for the remainder of the build. Two is correct.

## Hook config file: `.claude/settings.json` (not `.claude/hooks.json`)

Current Claude Code docs confirm hooks live under the `"hooks"` key in `.claude/settings.json`. There is no `.claude/hooks.json` path — that would be silently ignored. Documented here so a future contributor doesn't re-discover this.

## Slash command directory: `.claude/commands/` (not `.claude/skills/`)

The current Claude Code docs note that custom commands have been merged into skills and `.claude/skills/<name>/SKILL.md` is the newer preferred form. We use the legacy `.claude/commands/<name>.md` form because:

- Each of the three commands is a single file with no supporting assets.
- One `.md` per command is easier to grep, diff, and update than a directory tree.
- The legacy form continues to be fully supported.

If a future command needs supporting files (bundled scripts, example templates, reference docs), it migrates to the `.claude/skills/<name>/` form at that point.

## PostToolUse reminder reaches Claude (not just the transcript)

`PostToolUse` stdout is logged to the session transcript but is NOT injected into Claude's context unless emitted as structured JSON. A plain `echo` in the hook would satisfy the user's eye but Claude would never see it. The hook script at `.claude/hooks/schema-modified.sh` outputs `hookSpecificOutput.additionalContext` so Claude receives the reminder as a system message on its next turn. This is a non-obvious behavior documented here to prevent future regression.

## Intentionally NOT modeled in v1

- **Subagent-specific hooks** — Phase 3 work, alongside the reconciliation orchestrator (row 3.7) and its parallel subagents.
- **MCP-server registration in `.claude/mcp.json`** — Phase 2 work, alongside `aegis-ontology-mcp` (row 2.7).
- **Eval-log `PostToolUse` hook** — Phase 5 work, alongside the eval harness (row 5.2).
- **`.claude/agents/` directory** — no stubs created; this directory lands in Phase 3 with its first agent definition.
- **`.claude/mcp.json`** — no stub created; this file lands in Phase 2 with the first MCP server registration.

## Consequences

- **Positive:** Every new Claude Code session in this repo inherits AEGIS conventions automatically. Chunk launches are one keystroke. The schema discipline is enforced by the toolchain, not by memory.
- **Negative / tradeoffs:** `.claude/settings.json` is now a file that future contributors (or Claude Code itself) must edit carefully — the hooks JSON schema is upstream-defined and easy to mis-shape silently.
- **Follow-ups required:**
  - Phase 2: add `aegis-ontology-mcp` registration to `.claude/mcp.json`; add subdirectory `CLAUDE.md` files per module (row 2.8).
  - Phase 3: add `.claude/agents/` with the reconciliation orchestrator subagent definition; add subagent-specific hooks.
  - Phase 5: add eval-log `PostToolUse` hook when the eval harness ships.
