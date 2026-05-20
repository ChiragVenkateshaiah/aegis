---
description: Launch a chunk prompt — reads AGENT_PRIMER.md, then docs/prompts/$ARGUMENTS, enters /plan mode honoring the Practice Header.
argument-hint: <day-slug>
---

You are starting a new AEGIS chunk: **$ARGUMENTS**.

Step 1. Read `AGENT_PRIMER.md` in full. The Practice Header (§3) and Practice Recap (§4) templates are load-bearing for every chunk.

Step 2. Read `docs/prompts/$ARGUMENTS.md`. The CCF-A Practice Header at the top of that file states the PRIMARY topic for this chunk and the topics deliberately NOT practiced — your plan must respect both.

Step 3. Enter `/plan` mode. Your plan must:
- Begin with a Context section explaining why this chunk is being done now.
- Honor every "DELIBERATELY NOT PRACTICED HERE" item in the chunk's Practice Header — don't drift into those topics.
- Reference existing files and conventions rather than re-inventing.
- Include an Acceptance check tied to the deliverables listed in the chunk prompt.
- End with a Verification section.

If `docs/prompts/$ARGUMENTS.md` does not exist, stop immediately and report: "File not found: docs/prompts/$ARGUMENTS.md — cannot launch chunk." Do not invent a chunk prompt.
