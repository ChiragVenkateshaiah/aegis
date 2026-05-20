# Day 01.5 Learning Report — Claude Code Workflow Surfaces

**Date:** 2026-05-19
**Chunk:** Day 01.5 — Wire up Claude Code workflow surfaces
**Phase:** 1 — Foundation
**CCF-A primary:** T2 Claude Code Configuration & Workflows (20%)

---

## 1. What we built and why

### CLAUDE.md — project memory at repo root

`CLAUDE.md` is the file Claude Code reads automatically at the start of every session in this repo. Before it existed, opening a new Claude Code session meant Claude had no idea what AEGIS is, how files are organized, what conventions apply, or even that it should read `AGENT_PRIMER.md` first. The first line of CLAUDE.md is a hard directive — `**ALWAYS read AGENT_PRIMER.md before reading anything else in this repo.**` — because without that anchor, the CCF-A practice tagging drifts within the first message. Beyond the anchor, the file contains the project summary, a concise file map (what lives where), coding conventions (provenance columns, RESTRICT cascade, JSONB shape), model selection rules, the Cowork/Claude Code boundary, and a "don't touch" list for frozen files. Without CLAUDE.md every Claude Code session starts cold: conventions have to be re-explained, the operator has to paste context, and the "read AGENT_PRIMER.md first" rule is enforced only by memory. With it, every session inherits the full AEGIS context in under 60 lines.

### Three slash commands — `/aegis-plan`, `/aegis-status`, `/aegis-recap`

The three slash commands under `.claude/commands/` are single-keystroke entry points for the three most common workflow actions in this build.

`/aegis-plan <slug>` solves the cold-start problem for a new chunk. Instead of pasting a long system prompt reminding Claude to read AGENT_PRIMER.md first, honor the Practice Header, and enter `/plan` mode, the operator types `/aegis-plan day-02-slug` and the command expands into exactly those instructions. It also enforces a guard: if the chunk prompt file doesn't exist at `docs/prompts/<slug>.md`, the command stops and reports the missing file rather than letting Claude invent a prompt. Without this command, the risk is that chunk launches drift — someone forgets to paste the primer instruction, Claude starts planning without the Practice Header constraint, and the T2 practice tagging is lost.

`/aegis-status` gives the operator a single-command snapshot of three things at once: which PHASES.md rows are still open, which day-prompt files have unfilled Practice Recap placeholders (identified by `_<...>_` syntax in the recap section), and the current CCF-A coverage tally from CCF_A_MAPPING.md §5 cross-referenced against which PHASES rows are already ✅. Without this command, getting that same picture requires opening three files manually, cross-referencing them, and doing arithmetic. The command makes the Cowork→Claude Code handoff faster and reduces the chance of forgetting to close a recap.

`/aegis-recap <slug>` closes chunks correctly. It reads the git diff, infers the "actually exercised" fields from what actually changed, derives the drift check from the Practice Header's "DELIBERATELY NOT PRACTICED" list, and then asks the operator exactly one question — the surprise lesson — before writing the completed recap back into the prompt file. The one-question constraint is deliberate: asking more would slow down the close-out and make operators skip the recap entirely. Without this command, filling the Practice Recap is a manual copy-paste-from-template exercise that reliably gets skipped under time pressure.

### Two hooks — SessionStart + PostToolUse schema-modified

The two hooks in `.claude/settings.json` enforce discipline at the toolchain level rather than relying on operator memory.

The `SessionStart` hook fires when Claude Code opens the project and prints one line: `AEGIS — read AGENT_PRIMER.md first. CCF_A_MAPPING.md is the topic ledger.` It is the belt to CLAUDE.md's suspenders — CLAUDE.md instructs Claude to read AGENT_PRIMER.md, and the hook reminds the human operator to do the same. Together they close the gap where a distracted session skips the primer and starts chatting about Day 2 without the CCF-A tagging in view.

The `PostToolUse` hook on `Edit|Write` operations scoped to `data/schemas/*.sql` and `data/seeds/*.sql` fires after Claude edits a schema or seed file and injects a system reminder: "Schema or seed modified. Re-run `make schema-verify` against the aegis-pg container before declaring done." The hook is scoped narrowly to only the files where forgetting the check has real consequences (a broken migration that passes in-memory but fails against the real container). Without this hook, the reminder lives only in the acceptance check at the bottom of the chunk prompt — easy to miss when Claude is in the middle of a long edit loop.

### ADR-0013 — design record for the configuration surfaces

ADR-0013 is the written record of why these specific three commands and two hooks were chosen, what the alternatives were, and what was deliberately left out. Without the ADR, future contributors (including future Chirag) would see a `.claude/` directory with specific choices and no explanation: why `commands/` not `skills/`, why two hooks not five, why the PostToolUse hook is a script not an echo. ADRs are what prevent decisions from being re-litigated in every session. They also record the non-obvious behaviors (see §3 below) so they don't get "fixed" incorrectly by someone who doesn't know why the code is shaped the way it is.

---

## 2. The T2 principles this chunk exercised

### Row 1.7 — `CLAUDE.md`: project-level memory

**What T2 is testing here:** the CCF-A T2 topic covers how Claude Code is configured to carry persistent context across sessions. The exam tests whether candidates know that `CLAUDE.md` is Claude Code's project-memory primitive — it loads automatically at session start and scopes conventions, constraints, and references so Claude doesn't start cold.

**Which decision demonstrates this:** `CLAUDE.md` is 53 lines structured around the eight things Claude most needs to know at session start: the AGENT_PRIMER.md anchor, project summary, file map, coding conventions, model selection rule, workflow boundary, CCF-A practice rule, and common commands. The "don't touch" list at the bottom is equally important — it tells Claude what not to do, which is as load-bearing as what to do.

**Why an examiner would credit this as T2:** the file uses the correct Claude Code memory primitive (not a custom instruction appended to every prompt), is kept under the context budget constraint that makes it a recurring-cost decision (53 lines, not 500), and includes the operator/AI boundary (Cowork-maintained vs. Claude Code-editable) which is a T2 workflow design concept.

### Row 1.8 — Custom slash commands

**What T2 is testing here:** T2 includes the ability to design reusable workflow shortcuts using Claude Code's slash-command system — specifically, how `$ARGUMENTS` substitution works, what frontmatter fields are available (description, argument-hint), and how command bodies become prompt expansions. It also tests whether candidates understand when to use the legacy `.claude/commands/` form vs. the newer `.claude/skills/` form.

**Which decision demonstrates this:** all three commands use `$ARGUMENTS` for the day-slug parameter and include frontmatter `description` and `argument-hint` fields. The `/aegis-plan` command uses the guard pattern (`If docs/prompts/$ARGUMENTS.md does not exist, stop immediately`) which demonstrates prompt-safety design within a slash command. The choice of `.claude/commands/` over `.claude/skills/` was made explicitly with reasoning (single-file commands need no supporting assets) and documented in ADR-0013.

**Why an examiner would credit this as T2:** the commands use the correct argument substitution syntax, are structured to do specific workflow work rather than generic chat, and the design record explains a concrete decision between the two command-directory forms — exactly the kind of configuration trade-off T2 questions probe.

### Row 1.9 — Hooks

**What T2 is testing here:** T2 covers Claude Code hook configuration — the event types (`SessionStart`, `PostToolUse`, `PreToolUse`, etc.), the JSON structure in `.claude/settings.json`, how `matcher` and `if` fields narrow hook scope, and critically, how hook stdout behavior differs by event type (a non-obvious distinction the exam would probe).

**Which decision demonstrates this:** `.claude/settings.json` shows two correctly-scoped hooks: a `SessionStart` hook using simple `echo` (correct for that event type, where stdout reaches Claude), and a `PostToolUse` hook using a bash script that emits structured JSON via `hookSpecificOutput.additionalContext` (required for PostToolUse, where plain echo is silently swallowed). The `if` field in the PostToolUse entry uses permission-rule glob syntax to narrow scope to `data/schemas/*.sql` and `data/seeds/*.sql` — demonstrating understanding of hook scoping beyond the basic `matcher`.

**Why an examiner would credit this as T2:** it correctly distinguishes the stdout behavior of `SessionStart` vs. `PostToolUse`, implements the non-trivial JSON output pattern for the PostToolUse case, and uses both `matcher` (tool name filter) and `if` (path filter) to demonstrate layered scoping. A candidate who only knew that "hooks run a command" would have written a plain echo for both and the PostToolUse reminder would silently fail.

---

## 3. The non-obvious things

### PostToolUse stdout does NOT reach Claude without JSON

**Naive assumption:** hooks run shell commands, and a shell command that `echo`s text will print that text into the conversation where Claude can see it.

**Actual behavior:** `PostToolUse` stdout is logged to the session transcript but is NOT injected into Claude's context. Claude does not see it. Only `SessionStart` has the behavior most people assume — its stdout reaches Claude directly. For `PostToolUse` to inject a reminder into Claude's awareness, the hook script must emit a specific JSON structure: `{ "hookSpecificOutput": { "hookEventName": "PostToolUse", "additionalContext": "..." } }`. Claude Code reads this and promotes the `additionalContext` value to a system reminder on the next turn.

**Exam-relevant lesson:** knowing which hook event types deliver stdout to Claude (SessionStart: yes; PostToolUse: only via JSON) is the kind of behavioral detail that separates T2 "I've read the docs" knowledge from T2 "I've actually implemented a hook" knowledge. If you write a PostToolUse hook that echoes a message and it seems to work in testing (you can see the echo in the terminal), you might not notice Claude never saw it — until you check whether Claude's next response actually references the reminder.

### `.claude/commands/` was chosen over `.claude/skills/`

**Naive assumption:** the docs say `.claude/skills/<name>/SKILL.md` is the "new preferred form" — so you should use that.

**Actual behavior:** `.claude/commands/<name>.md` still works fully and is simpler for single-file commands with no supporting assets. The skills directory adds a per-command subdirectory that buys you the ability to bundle supporting files (scripts, templates, examples) but adds filesystem overhead you don't need if the command is just a markdown prompt expansion. The two forms are fully interchangeable for simple commands; the skills form is strictly for when you need those supporting files.

**Exam-relevant lesson:** "newer = better" is not always the right call in Claude Code configuration. The legacy form is still supported and is the correct choice when it's simpler. T2 questions about command authoring will test whether candidates know both forms exist and when each is appropriate — not just that one form is "preferred."

### Exactly two hooks, not more

**Naive assumption:** more hooks = more discipline. A pre-commit lint hook, a test-coverage check, an eval-log hook — why not add them all now?

**Actual behavior:** hooks that fire on events that don't yet have targets (no test suite in Week 1, no eval harness until Phase 5) create friction with no benefit. A pre-commit hook that runs a linter during rapid schema iteration in Week 1 would block legitimate commits. Hooks that fire constantly on non-existent targets train the operator to dismiss hook output as noise — exactly the opposite of what a well-scoped hook should do.

**Exam-relevant lesson:** hook design is a minimum-viable question, not a maximum-coverage question. The right hook fires precisely on the event it's meant to catch and never otherwise. Over-hooking is as much a T2 anti-pattern as under-hooking, and an examiner testing Claude Code workflow judgment would credit a candidate who explains *why they didn't add* a hook as readily as one who explains why they did.

---

## 4. One-line surprise lesson candidates

Pick whichever one best matches what genuinely surprised you during this chunk:

**Option A — hook stdout routing:**
> `PostToolUse` stdout is logged to the transcript but never reaches Claude's context unless emitted as structured JSON with `hookSpecificOutput.additionalContext` — a silent failure mode that looks correct in the terminal but isn't.

**Option B — commands vs. skills trade-off:**
> The newer `.claude/skills/<name>/SKILL.md` form is strictly more capable than `.claude/commands/<name>.md`, but "more capable" is a liability when you have no supporting assets to bundle — simpler form, less to maintain.

**Option C — hook scope layering:**
> Claude Code hooks have two independent scope layers — `matcher` filters by tool name and `if` filters by the tool's arguments (e.g., file path) — and both are needed to narrow a `PostToolUse` hook to only schema files without catching every `Edit` in the repo.
