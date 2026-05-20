# Day 1 of AEGIS — Reviving a Name, Rebuilding the Mission

*On carrying a project name forward, contract-first ontology design, and what 4.5 years in FinTech taught me about cross-document reconciliation.*

---

A credit analyst at a $20B community bank opens a fresh SME loan application. A small services business is asking for $400,000. On her desk: a business tax return, six months of bank statements, a handful of supporting docs. By the end of the day, she will have produced a credit memo: a structured narrative explaining, with citations, why the bank should or should not extend the loan.

That memo will take her about six hours.

Most of those hours will not be spent on judgment. They will be spent on reconciliation — cross-checking that the revenue line on the tax return is consistent with deposits in the bank statements, that declared owner draws match the cash actually withdrawn, that the debt service the borrower claims matches the loan obligations actually visible across documents. The judgment work — the part of the job that requires an experienced underwriter — sits underneath about five hours of careful, mechanical arithmetic.

I am building **AEGIS** to compress that six hours into about eight minutes, without taking the analyst's judgment out of the loop.

This is Day 1.

---

## Why the name AEGIS — again

If you have followed my work, you may recognize the name. The first AEGIS, a project I built earlier, was a multi-region transaction system — an exercise in keeping money flows consistent across geographies, networks, and failure modes. That project taught me a lot about distributed correctness. It also gave me a name I liked, and a name I never properly retired.

In Greek mythology, the aegis is the shield carried by Zeus, lent to Athena and Apollo, traditionally invoked as a symbol of *protection over what matters*. The first AEGIS protected the *flow* of money — transactions in motion. This AEGIS protects the *judgment* applied to money — decisions about whether to lend, to whom, and on what terms. Different surface area, same north star: shield financial systems from preventable bad outcomes.

I considered starting fresh with a new name. I decided against it for three reasons:

1. **Project names should compound, not multiply.** If I am building a portfolio that argues *"this engineer returns to first principles,"* the name continuity makes that argument better than a fresh name would. The reader sees a builder who refines, not one who churns.
2. **The mission is honestly the same.** The previous AEGIS was about correctness under distributed conditions. This AEGIS is about correctness under document-level adversity (messy PDFs, partial information, internally inconsistent borrower data). Both are *correctness projects*. The shield metaphor holds.
3. **I was not done with the name.** The first AEGIS was a learning project. It taught me how I think about reliability. Carrying the name forward into a project where reliability is a *load-bearing customer feature* — not a hobbyist concern — feels right.

So: AEGIS continues. New form. Same shield.

---

## What AEGIS is, in one sentence

AEGIS is an **AI credit memo / underwriting co-pilot for SME lending**. The 60-second demo is the forcing function for v1:

> A credit analyst at a $20B community bank receives an SME loan application. She drag-and-drops two PDFs — a business tax return and six months of bank statements — into AEGIS. The ontology populates live. She sees a pre-populated credit memo with every claim citing back to specific PDF pages. Three exception flags are highlighted, including *"Reported revenue $2.4M, bank deposits suggest $1.7M — flag for review."* She clicks the flag, sees the discrepancy with source pages highlighted, makes one edit, approves, and sends to committee. Eight minutes elapsed vs. six hours traditionally.

That is the demo I am building toward over eight weeks of evenings and weekends.

---

## Day 1: a contract before any consumers

The first instinct on a project like this is to start with the LLM-shaped problem: pull a tax return PDF into Claude, get a JSON back, look at it, smile, move on.

I deliberately did not do that on Day 1.

Every later component of AEGIS — extraction, reconciliation, ratio computation, memo generation — will produce or consume *structured facts about a borrower*. If those facts do not have a clean shape, every downstream component will invent its own private shape, and the project will collapse into a knot of dictionary keys passed between modules. The reconciliation engine cannot ask *"is the tax return's revenue consistent with the bank statement's deposits?"* unless there is a single answer to *"what is a revenue line item, and where did it come from?"*

So Day 1 was contract-first ontology design. The output is a Postgres schema and the decisions behind it.

### The 12 entities

The v1 ontology has twelve core tables:

```
borrower            — the legal applicant
entity              — the operating business (a borrower can have ≥1)
financial_period    — a quarter, year, or arbitrary span
document            — abstract source PDF
tax_return          — a 1120 / 1120S / 1065 (extends document)
bank_statement      — a monthly statement (extends document)
line_item           — an extracted financial fact (revenue, expense, deposit, …)
ratio               — DSCR, current ratio, debt service, working capital, owner DTI
reconciliation      — a cross-document check instance
exception_flag      — a surfaced inconsistency or threshold breach
memo                — the generated credit memo
memo_citation       — claim → source page/bbox linkage
```

These are not arbitrary. They came directly from sitting with the question *"what does an underwriter actually look at on their desk?"* — a question my prior years in FinTech had already half-answered for me.

### Provenance is not an afterthought

The most important Day 1 decision is invisible from the entity list above: every fact-bearing row in AEGIS carries **provenance columns**.

```
source_document_id   uuid
page_number          int        (1-indexed)
bounding_box         jsonb      (optional)
extractor_model      text
extractor_version    text
confidence           numeric    (0–1)
raw_blob             jsonb      (raw extracted blob for re-derivation)
```

This is the part most credit-AI demos quietly skip. They extract a number, drop it into a memo, and hope no one asks where it came from. That works on the demo stage. It does not work in front of a regulator, an internal audit team, or — most importantly — a senior underwriter who learned early in her career to never trust an unsourced number.

If a credit memo claims *"trailing-12-month revenue is $2.4M,"* AEGIS must be able to point to the exact page of the exact document the claim came from, the model that extracted it, and the confidence the system had at the time. That is not optional. It is the substrate of every other feature, including the differentiator I will describe in a moment.

In CCF-A terms (the Anthropic certification I am also deliberately practicing for during this build), Day 1 is a **Context Management & Reliability** chunk. Reliability work begins at the schema layer, not at the agent layer.

### The inheritance decision

A small but real architectural call: should `tax_return` and `bank_statement` inherit from `document` via *single-table inheritance* (one `documents` table with a `kind` discriminator) or *table-per-subtype* (separate `tax_returns` and `bank_statements` tables sharing a foreign key to `documents`)?

I went with table-per-subtype. The reasoning is in the ADR, but the short version: a 1120 tax return has roughly thirty fields worth modeling as columns; a monthly bank statement has none of those fields (it has transactions, which are their own table). Forcing both into one wide table would either explode the column count or push everything into JSONB, which defeats the purpose of having a relational ontology in the first place.

This is the kind of decision that costs nothing to get right on Day 1 and several weeks of refactoring to fix in Week 5.

---

## The differentiator, and why the BA background matters

Most AI underwriting demos do roughly one thing well: they read documents and summarize. That work is increasingly commoditized. Six months from now, *"my product reads tax returns"* will be a yawn.

The thing AEGIS is built around — the moment in the demo where a hiring manager sits up — is **cross-document reconciliation**. Three checks in v1:

1. **Tax return revenue vs. bank deposits.** If a borrower's 1120S declares $2.4M in revenue but six months of bank statements show $850K in deposits (annualized to ~$1.7M), AEGIS flags that. Could be legitimate (cash-heavy business, retained earnings, non-bank settlement). Could be a problem. The analyst decides.
2. **Declared owner draws vs. actual bank withdrawals.** A common SME pattern: the tax return shows modest owner compensation, but the operating account shows recurring large outflows to the owner's personal account. Material when underwriting a loan that depends on the borrower's discipline.
3. **Debt-to-income consistency.** The borrower's stated obligations should be visible — and only those obligations should be visible — across the documents.

I did not derive these checks from a textbook. I derived them from watching how underwriters actually work, in conversations across 4.5 years of business-analysis work in FinTech. Cross-document inconsistency is the single most common form of "interesting" that an experienced underwriter spends time on. The AI tools currently on the market mostly do not solve for it because the people building them are coming from the *document* side (extraction) rather than the *underwriting* side (judgment).

The schema I described above was designed to make those checks easy to express. The `reconciliation` table is a first-class entity. Each reconciliation produces an `exception_flag` with severity, status, and citations back to the line items it disagreed about. None of that is bolted on. It was there in the contract on Day 1.

This is the half of the project that benefits most directly from a Business Analyst's eye for *what is actually being asked of the system* — and from years spent in FinTech understanding what the back-office of a lender feels like at 5pm on a Friday.

---

## The dual purpose

AEGIS is also deliberate practice for **Anthropic's CCF-A certification**, which I am preparing to sit in the coming months. The certification covers Agentic Architecture & Orchestration, Tool Design & MCP Integration, Claude Code Configuration & Workflows, Prompt Engineering & Structured Output, and Context Management & Reliability. The project's eight weeks were laid out so that the depth of practice on each topic roughly matches that topic's weight on the exam.

Day 1 was a Context-Management-&-Reliability chunk. The provenance/evidence model is exactly the kind of structural reliability decision the exam exists to test for. Building it for a real product, not a toy, is how I want to study.

---

## What's next

Day 2 is the OCC credit memo template study — a reading-and-note-taking exercise, no code. The output is a structured understanding of what a v1 memo must contain and which citation patterns are conventional in regulated underwriting. That document will become the skeleton for the memo generator in Phase 4.

The thing I am most excited to build, the reconciliation orchestrator with parallel subagents that runs the three checks above, is Phase 3, weeks four and five. I will be writing about that one too.

---

If you are working in AI for finance — especially anywhere near SME lending, underwriting, or credit risk — I would love to compare notes. The corner of the market I am building toward (US community banks, $5B–$50B AUM, plus US/UK SME-lending fintechs) is large, under-served by current tooling, and full of analysts who would give back a third of their week for a tool that did the boring four-fifths of memo prep correctly.

More on Day 2 soon.

— Chirag

---

*Aegis is being built in public. Source, decision log, and phased plan live at [the project repository](https://github.com/) (link to be added).*

*If this resonated, follow me here on Medium or on LinkedIn — I'll be posting a Day NN entry weekly through the end of the build.*
