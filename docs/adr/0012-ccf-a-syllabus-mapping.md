# ADR-0012: CCF-A syllabus mapping baked into the project plan

**Date:** 2026-05-16
**Status:** Accepted

## Context

AEGIS is being built as an FDE portfolio project: an AI credit-memo co-pilot for SME lending, ~8 weeks of evening blocks. Independently, the operator is preparing for Anthropic's **CCF-A** (Claude Certified Foundations — Architect) certification. Doing the two things sequentially — finish AEGIS, *then* study — would mean the build skips topics the exam weights heavily (Agentic Architecture, MCP integration, Claude Code workflow surfaces) precisely because product-driven 8-week builds tend to take the shortest path. Doing the two things in parallel without an explicit mapping would mean we'd hand-wave "yeah, this practices agents" without measuring whether the build actually exercises each topic in proportion to its exam weight.

We need the parallel approach, but with the mapping made explicit and stable up front.

## Decision

Bake the CCF-A syllabus into the project plan as a first-class concern. Specifically:

1. **Tag every deliverable** in [PHASES.md](../../PHASES.md) with a primary CCF-A topic (and secondary topics when applicable). Deliverables that don't exercise an exam topic are tagged `—` rather than stretched.
2. **Maintain a coverage table** in [CCF_A_MAPPING.md](../../CCF_A_MAPPING.md) that converts deliverables to weighted points and shows the total share each topic gets. The table must hit each exam weight within ±1pp.
3. **Add the deliverables required to close gaps**, but bounded by the anti-overengineering constraints in §"Constraints" below.
4. **Operationalize practice per-chunk** via the CCF-A Practice Header and Practice Recap defined in [AGENT_PRIMER.md](../../AGENT_PRIMER.md). Every Day prompt opens with the header and closes with the recap. Both Cowork and Claude Code CLI read AGENT_PRIMER.md at session start.

The exam weights and our coverage (all hits ±0%):

| ID | Topic | Weight | AEGIS coverage |
|----|---|---:|---:|
| T1 | Agentic Architecture & Orchestration | 27% | 27% |
| T2 | Claude Code Configuration & Workflows | 20% | 20% |
| T3 | Prompt Engineering & Structured Output | 20% | 20% |
| T4 | Tool Design & MCP Integration | 18% | 18% |
| T5 | Context Management & Reliability | 15% | 15% |

## Constraints (anti-overengineering)

These constraints are part of the decision; without them, the mapping would inflate the build past 8 weeks.

- **Two MCP servers, total.** `aegis-ontology-mcp` (Phase 2) and `aegis-eval-mcp` (Phase 5). Anything else gets cut.
- **No custom agent framework.** All multi-agent work uses Claude Code's subagent primitive.
- **15%-weight topics get one deep deliverable, not five shallow ones.** T5 anchors in the eval harness; T4 anchors in the two MCP servers.
- **No Next.js until Streamlit is shipping.** UI polish is not on the CCF-A critical path.
- **Every CCF-A deliverable must be load-bearing for the product.** No box-ticking work.

## Alternatives considered

- **Study CCF-A separately after AEGIS ships.** Rejected: doubles the calendar cost. Also, AEGIS without agentic orchestration, MCP surfaces, and proper reliability scaffolding would be a weaker portfolio piece — the exam topics happen to also be the production-quality bar. The two goals reinforce each other when integrated.
- **Tag deliverables with CCF-A topics but don't add new ones.** Rejected: the original 8-week plan under-covers T1 (Agentic Architecture), T2 (Claude Code workflow surfaces), and T4 (MCP). We'd hit ~10% on T1 by accident, leaving a 17pp gap relative to the exam weight.
- **Build a richer agent framework to maximize T1 practice.** Rejected: violates "no custom agent framework"; CCF-A is *Foundations* — Architect, not a framework-building exam. The subagent primitive in Claude Code is the right surface to practice.
- **Three MCP servers instead of two** (e.g., a separate one for ratios). Rejected: ratios are better practiced as typed non-MCP tools (T4 has two distinct sub-skills — tool design *and* MCP — and we cover both with fewer servers).

## Consequences

**Positive**

- Time spent on the portfolio piece doubles as exam-weighted study. Phase 5 ends with a CCF-A study log (rolled-up Practice Recaps) ready for review.
- The build acquires real agentic orchestration (reconciliation orchestrator with parallel subagents, memo composer + citation subagent, LLM-as-judge agent), MCP surfaces, and reliability scaffolding it would otherwise have hand-waved. The portfolio piece is stronger as a result.
- The mapping is *legible*: a hiring manager reviewing the case study can see how each phase's deliverables practice specific competencies, which itself supports the FDE positioning.

**Negative / tradeoffs**

- Adds 9 deliverables (1.7, 1.8, 1.9, 2.7, 2.8, 3.7, 4.5, 5.7, 5.8) to the original plan. Each one is justified individually in [CCF_A_MAPPING.md §4](../../CCF_A_MAPPING.md), but the build is now denser. We accept this — the additions are load-bearing for product quality.
- Every chunk pays a small overhead for the Practice Header + Recap (~3 minutes per chunk). Worth it; without the recap, the study log doesn't materialize.
- Locking the mapping early means a mid-build re-tag (e.g., if we discover a deliverable practices something we didn't anticipate) requires a new ADR. That friction is intentional.

**Follow-ups required**

- Day 1 prompt ([`docs/prompts/day-01-ontology-schema.md`](../prompts/day-01-ontology-schema.md)) is prepended with its CCF-A Practice Header (T5 PRIMARY).
- Each subsequent Day prompt opens with a header and closes with a recap; see [AGENT_PRIMER.md](../../AGENT_PRIMER.md) §3–§4 for templates.
- New deliverables 1.7 / 1.8 / 1.9 get their own Day prompts in Week 1 (or fold into existing chunks if they're small enough).
- If the operator's exam-readiness assessment in Week 6 shows a gap, a re-balancing ADR is opened *before* Phase 5 starts.
