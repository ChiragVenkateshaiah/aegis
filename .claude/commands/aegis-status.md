---
description: Print current phase row statuses, list day-prompt files with unfilled Practice Recaps, and show the CCF-A coverage tally from CCF_A_MAPPING.md §5.
---

Print three sections, in this order. Be terse — this is a status snapshot.

## 1. Active phase rows

Read `PHASES.md`. Find the first phase whose row table contains any `☐` or `◐` rows — that is the active phase. Print the phase header line and every row in that phase's deliverable table verbatim, preserving the pipe-table format. Status legend: ☐ not started · ◐ in progress · ✅ done · ✖ skipped.

## 2. Chunks with unfilled Practice Recaps

For every file matching `docs/prompts/day-*.md`:
- Locate the `## Practice Recap — Day NN` heading. If absent, note "missing recap section".
- If present, scan the block beneath it for placeholder syntax: `_<...>_`, `_YYYY-MM-DD_`, `_~Nh_`, `<one line`, `<filled in`, or any line that is a template token rather than actual content.
- If unfilled placeholders remain, list: `filename — unfilled fields: <comma-separated list>`.
- If fully filled, skip it.

## 3. CCF-A coverage tally

Read `CCF_A_MAPPING.md` §5 and print the coverage table verbatim.

Then, cross-reference PHASES.md: for each deliverable that is ✅ in PHASES.md, note its topic and point value from the §5 table. Print a one-line summary per topic showing banked points vs. total allocated, e.g.:
`T2 Claude Code: 0/20 banked (0 pts of 20 pts — 1.7 ✅ 1.8 ✅ 1.9 ✅ still needed: 2.8, 3.7 subagent, 4.5 subagent)`
