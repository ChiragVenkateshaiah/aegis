---
description: Fill the Practice Recap at the bottom of docs/prompts/$ARGUMENTS using the AGENT_PRIMER.md §4 template. Infers everything except the surprise lesson.
argument-hint: <day-slug>
---

You are filling the Practice Recap at the bottom of `docs/prompts/$ARGUMENTS.md`.

Step 1. Read `AGENT_PRIMER.md` §4 for the exact Recap template — match its formatting precisely (headings, indentation, bold markers, field order).

Step 2. Read `docs/prompts/$ARGUMENTS.md` in full. Note:
- The Practice Header at the top — gives you PRIMARY topic, SECONDARY topics, DELIBERATELY NOT PRACTICED list, and the CCF_A_MAPPING.md row reference.
- The Deliverables list — what was supposed to ship.

Step 3. Run `git log --oneline -- src/ data/ docs/ evals/` and `git diff HEAD~1..HEAD --stat` to see what actually changed in this chunk. Use judgment to identify which commit marks the start of this chunk; ask the operator if genuinely ambiguous.

Step 4. Derive these fields by inference — do NOT ask the user about them:
- `Date completed:` today's date (YYYY-MM-DD).
- `Intended primary topic:` copy from Practice Header.
- `Actually exercised:` one bullet per topic the diff genuinely exercised — one concrete sentence per topic citing what you saw in the diff. Include SECONDARY topics only if the diff showed real practice, not just incidental touch.
- `Drift check:` Y/N based on whether any "DELIBERATELY NOT PRACTICED" topics appeared in the actual diff. If Y, one line on what happened.
- `Cross-ref:` copy from Practice Header.

Step 5. Ask the operator EXACTLY ONE question — phrased verbatim as:
"What's the single thing you didn't know at the start of this chunk that you do now? (One line, exam-relevant only.)"

Wait for the answer, then fill in `Surprise lesson`.

Step 6. Write the completed Recap into `docs/prompts/$ARGUMENTS.md`, replacing any existing placeholder block under the `## Practice Recap` heading. Do not add commentary outside the Recap section. Do not modify anything above that heading.
