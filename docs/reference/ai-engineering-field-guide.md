# AI Engineering Field Guide
## AEGIS — Day 1 Reference: Schema, Principles, and CCF-A Mapping

> **What this document is:** A durable reference guide written after Day 1 of the AEGIS build.
> It explains the SQL schema in use-case terms, the relationships between every file produced,
> the CCF-A exam topic mapping, and five transferable AI engineering principles you can apply
> to any production AI system — not just AEGIS.
>
> **When to read this:** Before debugging the ontology layer. Before starting Phase 2.
> Before any session where you've forgotten why a design decision was made.
> Before the CCF-A exam.
>
> **Companion docs:** `data/schemas/ontology.sql`, `data/schemas/erd.md`,
> `docs/adr/0011-ontology-design-choices.md`, `CCF_A_MAPPING.md`, `AGENT_PRIMER.md`

---

## Table of Contents

1. [The Problem, Stated Precisely](#1-the-problem-stated-precisely)
2. [The SQL Explained — Table by Table](#2-the-sql-explained--table-by-table)
3. [File Relationships and Dependency Map](#3-file-relationships-and-dependency-map)
4. [CCF-A Day 1 Mapping — T5 Deep Dive](#4-ccf-a-day-1-mapping--t5-deep-dive)
5. [CCF-A Full Topic Map (All 8 Weeks)](#5-ccf-a-full-topic-map-all-8-weeks)
6. [Five Transferable AI Engineering Principles](#6-five-transferable-ai-engineering-principles)
7. [Debugging Cheat Sheet](#7-debugging-cheat-sheet)

---

## 1. The Problem, Stated Precisely

Before the schema makes sense, the problem must be precise.

**What a credit analyst does manually (6 hours):**

```
Receive 2 PDFs (tax return + bank statements)
  → Read tax return: find revenue, expenses, deductions
  → Read bank statements: find deposits, withdrawals
  → Mentally cross-check: "do reported revenues match what went through the bank?"
  → Compute ratios: DSCR = Net Operating Income / Annual Debt Service
  → Write a 4-page memo: "Acme LLC earns $1.2M, DSCR 1.25x, flag: $24K deposit gap"
  → Cite every claim: "Revenue — Form 1120S page 2, line 1c"
```

**What AEGIS does with AI (8 minutes):**

```
Receive 2 PDFs
  → Extract  → store facts in the ontology database
  → Reconcile → compare facts across documents, surface gaps
  → Compute  → calculate ratios from stored facts
  → Generate → write memo, every sentence citing a DB row that cites a PDF page
```

**The database is the brain.** Every intelligence step reads from and writes to the ontology.
Nothing in the pipeline holds state in memory — all state lives in Postgres.
That is why Day 1 is the schema: nothing else can be built until the contract exists.

---

## 2. The SQL Explained — Table by Table

The 13 tables answer one question each:
**Who is the borrower? What did they submit? What did we find? What did we say about it?**

### Layer 1 — Identity (Who?)

```
borrowers   → The legal applicant: "Acme Restaurant Group LLC, EIN 12-3456789"
owners      → Person behind the business: "Jane Doe, 100% owner, credit score 720"
entities    → The operating company: NAICS 722511 = Full-Service Restaurants
```

**Why `borrowers` and `entities` are separate tables:**

In SME lending, one person (borrower) can own multiple businesses (entities).
A restaurant operator might have:
- `Acme Restaurant Group LLC` — the holding company (the borrower, the guarantor)
- `Acme Burgers Operating LLC` — the entity that files taxes and has the bank account

Your loan analysis runs against the *entity* financials,
but your guarantee and liability run against the *borrower*.
The separation matters the moment a borrower has two entities applying for two loans.

**Why `owners` is a table, not columns on `borrowers`:**

One borrower can have multiple owners (50/50 partnership, three-way split).
Columns on `borrowers` can only hold one owner.
A table allows `SELECT * FROM owners WHERE borrower_id = X` to return all guarantors.

---

### Layer 2 — Time (When?)

```
financial_periods  → "FY2023: Jan 1 2023 to Dec 31 2023"
                   → "Q3-2023: Jul 1 to Sep 30 2023"
                   → "TTM-Dec-2023: trailing 12 months ending December 2023"
```

**Why no UNIQUE constraint on date ranges (overlapping periods allowed):**

A bank analyst often needs *both* annual and trailing-12-month views simultaneously.
Annual = aligns with the tax return filing period.
Trailing-12-month = used when the fiscal year doesn't align with calendar year,
or when the analyst wants to normalize a mid-year application.

If you put `UNIQUE(entity_id, start_date, end_date)`, you block legitimate overlapping periods.
Without the constraint, both can coexist. The `label` column ("FY2023", "TTM-Dec-2023")
gives humans the semantic distinction.

**The `label` column is not redundant.** You could compute `FY2023` from `start_date` and
`end_date`, but that computation depends on assumptions (fiscal vs. calendar year, naming
convention). Storing the label explicitly decouples display from computation.

---

### Layer 3 — Source Documents (What was submitted?)

```
documents       → Base record: "acme-1120s-2023.pdf, 42 pages, SHA-256 hash"
tax_returns     → Subtype: "Form 1120S, tax year 2023, preparer: Ace Accounting LLC"
bank_statements → Subtype: "Chase Bank, account ending 7890, January 2023"
```

#### The Inheritance Decision: TPT (Table-Per-Subtype)

This is the most important architectural decision in the schema.
You had two choices:

**Option A — Single table with NULL columns (STI, Single Table Inheritance)**

```sql
documents (
  id, borrower_id, doc_type,
  form_type, tax_year, preparer_name,   -- NULL for bank statements
  bank_name, account_number_last4, statement_month  -- NULL for tax returns
)
```

Every `bank_statement` row has 3 NULL columns. Every `tax_return` row has 3 NULL columns.
Adding a third doc type (personal 1040) means more NULLs, more confusion.

**Option B — Table-per-subtype (TPT) — what AEGIS uses**

```sql
documents (id, borrower_id, doc_type, filename, file_hash, page_count)
tax_returns (id → documents.id, form_type, tax_year, preparer_name)
bank_statements (id → documents.id, bank_name, statement_month)
```

**The key trick: shared-PK pattern.**
`tax_returns.id` is *both* the primary key *and* a foreign key to `documents.id`.
One row in `tax_returns` IS one row in `documents`. To get a full tax return:

```sql
SELECT d.*, t.form_type, t.tax_year
FROM documents d
JOIN tax_returns t ON t.id = d.id
WHERE d.id = 'aaaaaaaa-0005-...';
```

To add a third doc type (personal 1040 in Phase 3): create a new table, zero ALTER required.

**When to use TPT vs. STI in practice:**

| Situation | Use |
|---|---|
| Subtypes have many different columns (4+) | TPT |
| You'll add subtypes in future phases | TPT |
| Subtypes share 80%+ of columns, few unique ones | STI |
| You need maximum query simplicity | STI |

AEGIS uses TPT because `tax_returns` and `bank_statements` have meaningfully different column
sets and a third doc type (1040) is already anticipated.

---

### Layer 4 — Extracted Facts (What did the AI find?)

```
line_items → Atomic financial facts: "Gross receipts $1,200,000 (page 2, bbox)"
```

This is where Claude does its work.
Every time the extraction pipeline reads a PDF and finds a number, it creates a `line_items` row.

**The two parts of every line_item row:**

**Part 1 — The fact itself:**
```sql
category    = 'revenue'
label       = 'Gross receipts'
amount      = 1200000.00
currency    = 'USD'
```

**Part 2 — The provenance block (this is T5):**
```sql
source_document_id = 'aaaaaaaa-0005-...'      -- which PDF
page_number        = 2                         -- page 2 of the 1120S
bounding_box       = '{"x0":100,"y0":200,...}' -- exact pixel location
extractor_model    = 'claude-3-5-sonnet-20241022'
confidence         = 0.970                     -- 97% confident
raw_blob           = '{"raw_text":"Gross receipts or sales    1,200,000"}'
```

**Why the provenance block is load-bearing, not optional:**

Without it, your AI system is a black box. When the memo says "revenue is $1.2M",
you can't verify it, trace it, or debug it when it's wrong.

With it, every number has a chain of custody:

```
memo: "Revenue $1.2M"
  ↓ memo_citations.line_item_id
line_items.label = "Gross receipts", amount = 1200000.00
  ↓ line_items.source_document_id
documents.filename = "acme-1120s-2023.pdf"
  ↓ line_items.page_number + bounding_box
Page 2, box {x0:100, y0:200, x1:400, y1:220}
  ↓ line_items.extractor_model + confidence
claude-3-5-sonnet-20241022, 97% confidence
  ↓ line_items.raw_blob
{"raw_text": "Gross receipts or sales    1,200,000"}
```

When the system extracts $120,000 instead of $1,200,000, the `raw_blob` tells you whether
it was an OCR error (raw_text had a comma dropped), a model hallucination (raw_text was
correct but the model misread it), or an ambiguous field (two revenue lines on the same page).

**Why `currency CHAR(3)` even in a USD-only v1:**

If you don't store currency now, migrating later means `ALTER TABLE line_items ADD COLUMN currency CHAR(3) DEFAULT 'USD'` on a table with millions of rows. Storing it now costs one column; omitting it costs a migration. Always include the currency column.

---

### Layer 5 — Intelligence (What did we compute and check?)

```
ratios          → Computed: DSCR = 1.25 (NOI $450K / Debt Service $360K)
reconciliations → Cross-doc check: "deposits $1.176M vs reported $1.2M → $24K gap"
exception_flags → Surfaced inconsistency: "revenue_variance, severity: medium, open"
```

**The reconciliation is the differentiator.**

Every other AI underwriting tool extracts and summarizes. AEGIS also *compares across documents*.
The `reconciliations` table holds the result of: "Does the bank statement story match
the tax return story?"

```sql
recon_type     = 'deposit_to_revenue'
status         = 'fail'
delta_amount   = -24000.00   -- bank deposits are $24K lower than reported revenue
finding_summary = "Annualized deposits $1,176,000 are $24K below reported $1,200,000"
```

The `exception_flags` table makes that finding actionable for the analyst:
```sql
flag_type   = 'revenue_variance'
severity    = 'medium'    -- 2% gap, within 5% threshold → not critical
status      = 'open'      -- analyst hasn't reviewed yet
description = "Annualized deposits imply $1.18M vs $1.20M — warrants clarification"
```

**The status workflow:**
```
open → resolved  (analyst confirmed the gap is explainable)
open → waived    (analyst decided the gap is immaterial)
```

This is a first-class workflow, not a log message. It's queryable:
```sql
SELECT * FROM exception_flags
WHERE severity IN ('high', 'critical') AND status = 'open';
```

**Why `ratios` stores `numerator_snapshot` and `denominator_snapshot` as JSONB:**

DSCR = NOI / Annual Debt Service. NOI is derived from multiple `line_items` rows.
If you only store the final ratio value (1.25), you can't audit it: which line_items
contributed to the NOI? What if one of them was corrected after the ratio was computed?

The snapshot captures the inputs at the moment of computation:
```json
numerator_snapshot: {
  "noi": 450000,
  "line_item_ids": ["aaaaaaaa-0007-...-0001", "aaaaaaaa-0007-...-0002"]
}
denominator_snapshot: {
  "annual_debt_service": 360000
}
```

Now you can re-derive or audit the ratio without re-running the pipeline.

---

### Layer 6 — Output (What did we say?)

```
memos          → The generated credit memo document
memo_citations → Every claim anchored to its source evidence row
```

**Why `memo_citations` is a separate table and not embedded in `memos.body_markdown`:**

If citations were inline markdown links inside the body text, they'd be:
- Hard to query ("which claims cite this line_item?")
- Hard to validate ("does every claim have a citation?")
- Hard to update ("if a line_item is corrected, which memo sentences are affected?")

As a separate table, every citation is a structured row:
```sql
memo_id          → the memo this citation belongs to
line_item_id     → the extracted fact being cited (nullable)
ratio_id         → the computed ratio being cited (nullable)
reconciliation_id → the reconciliation finding being cited (nullable)
claim_text       → "Gross revenues of $1,200,000 for FY2023"
source_document_id, page_number, bounding_box  → the exact PDF location
```

The citation subagent in Phase 4 will iterate every claim in the memo body, attempt to
create a `memo_citation` row for it, and strike the claim if no citation can be created.
Ungrounded claims do not appear in the final memo.

---

## 3. File Relationships and Dependency Map

### What each file is

| File | Role |
|---|---|
| `data/schemas/ontology.sql` | The contract. Defines all 13 tables and 23 indexes. Everything binds to this. |
| `data/schemas/erd.md` | Human-readable diagram of ontology.sql. For onboarding, PRs, and debugging. |
| `data/seeds/seed_minimal.sql` | One complete fake borrower ("Acme Restaurant Group LLC") that exercises every table. |
| `data/schemas/check.sh` | Acceptance script. Verifies tables exist, row counts match, join query returns 2 rows. |
| `Makefile` | Orchestration. Runs DDL → seed → check in the right order. |
| `src/aegis/ontology/__init__.py` | Python package stub. Phase 2 puts SQLAlchemy ORM models here. |
| `docs/adr/0011-ontology-design-choices.md` | Decision record. WHY TPT, WHY inline provenance, WHY RESTRICT cascades. |

### Execution chain

```
make schema-apply
  │
  ├── psql < data/schemas/ontology.sql
  │     Creates 13 tables, 23 partial indexes
  │     Wrapped in BEGIN/COMMIT — all-or-nothing
  │
  └── psql < data/seeds/seed_minimal.sql
        Inserts: 1 borrower, 1 owner, 1 entity, 1 period,
                 2 documents (tax return + bank statement),
                 5 line items, 1 ratio, 1 reconciliation,
                 1 exception flag, 1 memo, 2 citations

make schema-verify
  │
  └── bash data/schemas/check.sh
        Checks: 13 tables exist
        Checks: row counts (1,1,1,1,2,1,1,5,1,1,1,1,2)
        Checks: memo→citation join returns 2 rows
        Prints: \dt table listing
```

### What breaks if you change what

```
ontology.sql  ←── EVERYTHING depends on this
    │
    ├── seed_minimal.sql      rename a column → update every INSERT that uses it
    │       │
    │       └── check.sh      change seed counts → update expected values in check
    │
    ├── src/aegis/ontology/__init__.py   Phase 2 ORM mirrors this exactly
    │
    └── ALL future Python modules (extraction, reconciliation, ratios, memo)
              bind to these table/column names

Makefile           ← orchestration only; changes rarely
docs/adr/0011-...  ← static record; update only when design decisions change
data/schemas/erd.md ← update when ontology.sql changes
```

### How to run from scratch

```bash
# Start a fresh Postgres 16 container
docker run -d \
  --name aegis-db \
  -e POSTGRES_USER=aegis \
  -e POSTGRES_PASSWORD=aegis \
  -e POSTGRES_DB=aegis \
  -p 5432:5432 \
  postgres:16

export DATABASE_URL=postgres://aegis:aegis@localhost:5432/aegis

# Apply schema + seed
make schema-apply

# Verify
make schema-verify
```

---

## 4. CCF-A Day 1 Mapping — T5 Deep Dive

**Day 1 primary topic: T5 — Context Management & Reliability (15% of exam)**

T5 is about building AI systems that are trustworthy by design — not just accurate on average,
but traceable, auditable, and recoverable when they fail.

### What T5 actually tests (exam-level breakdown)

| T5 concept | What the exam will ask | How Day 1 exercises it |
|---|---|---|
| **Provenance tracking** | How do you trace an AI output back to its source? | Every fact table carries `source_document_id`, `page_number`, `bounding_box` — chain of custody from memo claim to PDF pixel |
| **Confidence calibration** | How do you quantify and store model uncertainty? | `confidence NUMERIC(4,3)` with `CHECK (confidence BETWEEN 0 AND 1)` on every extracted row |
| **Re-derivation from raw state** | If a computation is wrong, how do you fix it without re-calling the LLM? | `raw_blob JSONB` on every fact row stores the original extracted context |
| **Reliable failure modes** | How do you ensure failures are explicit, not silent? | `ON DELETE RESTRICT` on evidence FKs; `exception_flags` as first-class rows; `status` columns with defined state machines |
| **Context inheritance** | How does context flow between pipeline steps without loss? | The ontology is the shared context. All pipeline steps (extract → reconcile → compute → generate) read/write the same tables |

### The T5 principle in one sentence

> A reliable AI system is one where every output can be traced to its source,
> every confidence score is stored, and deleting evidence is a deliberate error — not a quiet accident.

### Where T5 goes deeper in later phases

```
Day 1    → provenance schema (substrate: the columns are there)
Phase 2  → confidence calibration (2.4): verify scores are meaningful, not just stored
Phase 3  → mid-phase eval gate (3.6): don't advance until precision/recall targets met
Phase 4  → citation engine (4.2): ungrounded claims are removed, not kept
Phase 5  → eval harness (5.2): the deep T5 deliverable — measures accuracy end-to-end
```

Day 1 builds the *floor* — the structural foundation that every later reliability
deliverable stands on. If the provenance columns weren't here, you couldn't build
the citation engine (4.2) or the eval harness (5.2) without a migration.

---

## 5. CCF-A Full Topic Map (All 8 Weeks)

Exam weights: T1 27% / T2 20% / T3 20% / T4 18% / T5 15%

```
T5 — Context Management & Reliability (15%)
  1.3 → Ontology provenance columns         [Day 1 — done]
  2.4 → Per-field confidence calibration    [Phase 2]
  2.6 → Phase 2 eval gate                  [Phase 2]
  3.6 → Phase 3 eval gate                  [Phase 3]
  4.2 → Citation engine                    [Phase 4]
  5.2 → Eval harness (deep deliverable)    [Phase 5]

T2 — Claude Code Configuration & Workflows (20%)
  1.7 → CLAUDE.md at repo root             [Day 1.5]
  1.8 → Custom slash commands              [Day 1.5]
  1.9 → Hooks (pre-commit, post-tool-use)  [Day 1.5]
  2.8 → Per-module CLAUDE.md files         [Phase 2]

T3 — Prompt Engineering & Structured Output (20%)
  1.4 → Borrower persona JSON schema       [Week 1]
  1.5 → Synthetic corpus generation        [Week 1]
  2.2 → Tax-return extractor prompt        [Phase 2]
  2.3 → Bank-statement extractor prompt    [Phase 2]
  3.5 → Exception flag schema              [Phase 3]
  4.1 → Memo template prompt               [Phase 4]
  5.3 → LLM-as-judge rubric prompt         [Phase 5]

T4 — Tool Design & MCP Integration (18%)
  2.7 → aegis-ontology-mcp server          [Phase 2]
  3.4 → Ratio engine (typed tools)         [Phase 3]
  5.7 → aegis-eval-mcp server              [Phase 5]

T1 — Agentic Architecture & Orchestration (27%)
  2.5 → OCR fallback chain (baby pattern)  [Phase 2]
  3.7 → Reconciliation orchestrator        [Phase 3]
       → Parallel subagents (3 checks)
       → Merge + rank results
  4.5 → Memo composer + citation subagent  [Phase 4]
       → Two-agent pattern
  5.8 → LLM-as-judge orchestrator          [Phase 5]
```

**The dependency chain is also the learning sequence:**

```
T5 first   → build the reliable substrate (provenance, confidence, state)
T3 next    → prompt Claude to populate it with structured outputs
T4 after   → expose the ontology as MCP tools so agents can use it
T1 later   → orchestrate agents that use the tools to run the pipeline
T2 throughout → configure Claude Code's workflow at every phase
```

You can't orchestrate agents (T1) against tools (T4) that don't exist,
and you can't trust the tools if the data they write lacks provenance (T5).
The order is not arbitrary — it's a dependency chain.

---

## 6. Five Transferable AI Engineering Principles

These are the underlying principles behind every decision in the Day 1 schema.
They apply to any production AI system — not just AEGIS.

---

### Principle 1 — Contract First, Implementation Second

**The rule:** Define the data contract (schema, types, relationships) before building any logic.
Every consumer of the data binds to the contract, not to an implementation detail.

**Why it works:**
Logic changes constantly (better extraction prompt, new ratio formula, updated model).
The contract changes much less often.
If all four pipeline stages (extract → reconcile → compute → generate) bind to the same schema,
you can swap out any one without touching the others.

**When you'll be tempted to violate it:**
"Let's just get extraction working first, we can formalize the schema later."
This always ends with four modules that have incompatible assumptions about column names,
NULL semantics, and type widths — and a migration that breaks two of them.

**Applied to Day 1:**
`ontology.sql` was written before any Python module exists. The extraction layer (Phase 2),
the reconciliation engine (Phase 3), and the memo generator (Phase 4) are all contractually
bound to this schema today — before they're built.

**General rule:**
*When building with AI, the schema is the API. Write it first.*

---

### Principle 2 — Evidence is Non-Negotiable

**The rule:** Every AI-generated fact must carry its source. Not as a nice-to-have — as a
required, schema-level design.

**Why it works:**
LLMs hallucinate. When they do, you need to know *where* they hallucinated so you can fix
the specific extraction prompt, not rewrite the whole pipeline.
Evidence also enables human-in-the-loop review: the analyst can see exactly which PDF line
produced each claim. Without evidence, you can't trust any AI output in a regulated domain.

**The three levels of evidence:**

```
Level 1 (minimum): store source_document_id
  → you know which document, not which part

Level 2 (better): store source_document_id + page_number
  → you can point an analyst to the right page

Level 3 (production): source_document_id + page_number + bounding_box + raw_blob
  → you can highlight the exact text box in the UI and re-derive the value if wrong
```

AEGIS is built to Level 3. Most AI document systems are built to Level 1 at best.

**Applied to Day 1:**
The provenance block appears on five tables (`line_items`, `ratios`, `reconciliations`,
`exception_flags`, `memo_citations`). You cannot insert a line_item without specifying
at minimum `source_document_id`.

**General rule:**
*Never store an AI output without storing its provenance. Provenance is not metadata — it is the output.*

---

### Principle 3 — Design for the Failure Case, Not the Happy Path

**The rule:** The schema should make failures explicit and recoverable. Good AI system design
anticipates where the AI will go wrong and builds the recovery path into the data model.

**Why it works:**
AI systems fail in predictable patterns: low confidence extractions, cross-document
inconsistencies, hallucinated summaries. If your schema has a `confidence` column,
a `status` column, and an `exception_flags` table, failures are first-class citizens
with structured handling. If your schema doesn't, failures become log entries that
no one reads.

**The four failure-design patterns in AEGIS:**

```
1. confidence column      → low-confidence rows can be flagged for human review
                            SELECT * FROM line_items WHERE confidence < 0.80

2. reconciliations.status → failures are rows, not exceptions
                            recon.status = 'fail' triggers exception_flag creation

3. exception_flags        → structured triage workflow
                            severity = critical | high | medium | low
                            status   = open | resolved | waived

4. ON DELETE RESTRICT     → deleting evidence is a deliberate error, not a quiet accident
                            you cannot accidentally orphan a fact's source document
```

**Applied to Day 1:**
The entire `reconciliations` and `exception_flags` layer is a designed failure surface.
We know the AI will find discrepancies — we've designed the schema to capture and
workflow those discrepancies, not hide them.

**General rule:**
*Model the failure cases in your schema. If the failure isn't in your schema, you can't build a workflow around it.*

---

### Principle 4 — Make State Explicit and Queryable

**The rule:** Every meaningful state transition in your AI pipeline should be a column
in the database, not a log message or an in-memory flag.

**Why it works:**
AI pipelines are long-running and multi-step. You need to know, at any point, exactly
where in the pipeline each document/entity/memo is. If state lives in logs, you can't
answer: "Which reconciliations have status 'fail' and severity 'high' for borrowers
reviewed in the last 30 days?" You can answer this with columns.

**State machines in the AEGIS schema:**

```
memos.status:
  draft → review → final

exception_flags.status:
  open → resolved
  open → waived

reconciliations.status:
  review → pass
  review → fail

exception_flags.severity:
  low | medium | high | critical  (not a state machine — a classification)
```

**The test:** Can you answer this query?

```sql
SELECT b.legal_name, ef.flag_type, ef.severity
FROM exception_flags ef
JOIN entities e ON e.id = ef.entity_id
JOIN borrowers b ON b.id = e.borrower_id
WHERE ef.severity IN ('high', 'critical')
  AND ef.status = 'open'
  AND ef.created_at > now() - INTERVAL '30 days';
```

If yes, your state is queryable. If you'd need to parse logs to answer this, your state is not explicit.

**Applied to Day 1:**
Every pipeline-meaningful condition has a column. No state lives only in memory.

**General rule:**
*If it matters to a human, it should be a column. If it matters to the pipeline, it should be a column.*

---

### Principle 5 — Soft Delete Everything, Hard Delete Nothing

**The rule:** In an AI system that processes evidence, never permanently delete a row.
Mark it deleted (`deleted_at` timestamp), keep it in place, filter it out of normal queries.

**Why it works:**
Financial documents are evidence. An analyst may have made a decision based on a `line_item`
that later got "corrected." If you hard-delete the original row, you've destroyed the audit
trail. Soft delete preserves history while keeping normal queries clean.

**How the performance problem is solved:**
Adding `WHERE deleted_at IS NULL` to every query on a large table would be slow.
The solution is partial indexes — indexes that only include non-deleted rows:

```sql
-- This index only covers active rows. Deleted rows are excluded from the index.
-- The query planner uses this for: SELECT ... WHERE deleted_at IS NULL
CREATE INDEX idx_line_items_document
    ON line_items(document_id) WHERE deleted_at IS NULL;
```

23 partial indexes in `ontology.sql` follow this pattern. Normal queries are fast
because the index is compact (only active rows). Deleted rows are invisible to
normal queries but remain in the table for audit purposes.

**When to hard-delete:**
Hard deletion should be an explicit, authorized, audited operation (GDPR erasure request,
legal hold expiry). It should never happen automatically as a cascade side effect —
which is why `ON DELETE RESTRICT` is used on all evidence foreign keys.

**Applied to Day 1:**
Every table has `deleted_at TIMESTAMPTZ` (nullable). Every index that supports normal
queries uses `WHERE deleted_at IS NULL`.

**General rule:**
*In AI systems processing real-world evidence, deletion is the most dangerous operation.
Default to marking, not removing.*

---

## 7. Debugging Cheat Sheet

### "Why does this line_item have this value?"

```sql
SELECT
    li.label,
    li.amount,
    li.confidence,
    li.extractor_model,
    li.page_number,
    li.bounding_box,
    li.raw_blob,
    d.filename
FROM line_items li
JOIN documents d ON d.id = li.source_document_id
WHERE li.id = '<line_item_id>';
```

### "Which claims in this memo lack citations?"

```sql
-- memo_citations are the citations that exist
-- this query finds orphaned claims by checking if a claim exists without a citation
-- (requires application-level tracking of claims; the DB can tell you which
-- citations exist, not which claims in the markdown lack them)
SELECT * FROM memo_citations WHERE memo_id = '<memo_id>';
```

### "Which exception flags are open and high/critical severity?"

```sql
SELECT
    ef.flag_type,
    ef.severity,
    ef.description,
    b.legal_name AS borrower,
    fp.label AS period
FROM exception_flags ef
JOIN entities e ON e.id = ef.entity_id
JOIN borrowers b ON b.id = e.borrower_id
JOIN financial_periods fp ON fp.id = ef.financial_period_id
WHERE ef.severity IN ('high', 'critical')
  AND ef.status = 'open'
  AND ef.deleted_at IS NULL
ORDER BY ef.severity DESC, ef.created_at DESC;
```

### "Which reconciliations failed and what was the delta?"

```sql
SELECT
    r.recon_type,
    r.status,
    r.delta_amount,
    r.finding_summary,
    b.legal_name AS borrower,
    fp.label AS period
FROM reconciliations r
JOIN entities e ON e.id = r.entity_id
JOIN borrowers b ON b.id = e.borrower_id
JOIN financial_periods fp ON fp.id = r.financial_period_id
WHERE r.status = 'fail'
  AND r.deleted_at IS NULL
ORDER BY ABS(r.delta_amount) DESC;
```

### "What is the full chain from a memo claim back to the source PDF?"

```sql
SELECT
    mc.claim_text,
    li.label AS line_item_label,
    li.amount,
    d.filename AS source_pdf,
    mc.page_number,
    mc.bounding_box,
    mc.confidence,
    mc.raw_blob
FROM memo_citations mc
JOIN memos m ON m.id = mc.memo_id
LEFT JOIN line_items li ON li.id = mc.line_item_id
LEFT JOIN documents d ON d.id = mc.source_document_id
WHERE m.id = '<memo_id>';
```

### "What does a complete borrower look like in the DB?"

```sql
-- All documents for a borrower
SELECT d.doc_type, d.filename, d.page_count, fp.label AS period
FROM documents d
JOIN borrowers b ON b.id = d.borrower_id
JOIN financial_periods fp ON fp.id = d.financial_period_id
WHERE b.legal_name = 'Acme Restaurant Group LLC'
  AND d.deleted_at IS NULL;

-- All line items for an entity + period
SELECT li.category, li.label, li.amount, li.confidence
FROM line_items li
JOIN financial_periods fp ON fp.id = li.financial_period_id
JOIN entities e ON e.id = fp.entity_id
WHERE e.legal_name = 'Acme Restaurant Group LLC'
  AND fp.label = 'FY2023'
  AND li.deleted_at IS NULL
ORDER BY li.category, li.amount DESC;
```

### "The DDL failed to apply — what happened?"

```bash
# Run with verbose output
psql $DATABASE_URL -v ON_ERROR_STOP=1 -e -f data/schemas/ontology.sql

# Check if tables already exist (for re-runs)
psql $DATABASE_URL -c "\dt"

# Drop everything and start fresh (destructive — dev only)
psql $DATABASE_URL -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
make schema-apply
```

### "The seed failed — ON CONFLICT means it was idempotent, check the actual error"

```bash
# Run seed with verbose output to see which statement failed
psql $DATABASE_URL -v ON_ERROR_STOP=1 -e -f data/seeds/seed_minimal.sql
```

---

*Last updated: 2026-05-17 — Day 1 complete.*
*Next: Day 2 — OCC credit memo template study (reading, no code). See `WEEK_01_TASKS.md`.*
