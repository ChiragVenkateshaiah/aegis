# AEGIS Ontology — Entity Relationship Diagram

## Mermaid ERD

```mermaid
erDiagram
    borrowers {
        uuid id PK
        text legal_name
        text dba_name
        char ein
        text entity_type
        char state_of_formation
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    owners {
        uuid id PK
        uuid borrower_id FK
        text full_name
        numeric ownership_pct
        char ssn_last4
        smallint credit_score
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    entities {
        uuid id PK
        uuid borrower_id FK
        text legal_name
        text dba_name
        char ein
        text entity_type
        char state_of_formation
        char naics_code
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    financial_periods {
        uuid id PK
        uuid entity_id FK
        text period_type
        date start_date
        date end_date
        text label
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    documents {
        uuid id PK
        uuid borrower_id FK
        uuid entity_id FK
        uuid financial_period_id FK
        text doc_type
        text filename
        text file_hash
        integer page_count
        timestamptz uploaded_at
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    tax_returns {
        uuid id PK-FK
        text form_type
        smallint tax_year
        date fiscal_year_end
        text preparer_name
        timestamptz created_at
        timestamptz updated_at
    }

    bank_statements {
        uuid id PK-FK
        text bank_name
        char account_number_last4
        date statement_month
        text account_type
        timestamptz created_at
        timestamptz updated_at
    }

    line_items {
        uuid id PK
        uuid document_id FK
        uuid financial_period_id FK
        text category
        text subcategory
        text label
        numeric amount
        char currency
        boolean is_annualized
        uuid source_document_id FK
        integer page_number
        jsonb bounding_box
        text extractor_model
        numeric confidence
        jsonb raw_blob
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    ratios {
        uuid id PK
        uuid entity_id FK
        uuid financial_period_id FK
        text ratio_type
        numeric value
        jsonb numerator_snapshot
        jsonb denominator_snapshot
        uuid source_document_id FK
        integer page_number
        jsonb bounding_box
        text extractor_model
        numeric confidence
        jsonb raw_blob
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    reconciliations {
        uuid id PK
        uuid entity_id FK
        uuid financial_period_id FK
        text recon_type
        text status
        text finding_summary
        numeric delta_amount
        char currency
        uuid source_document_id FK
        integer page_number
        jsonb bounding_box
        text extractor_model
        numeric confidence
        jsonb raw_blob
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    exception_flags {
        uuid id PK
        uuid reconciliation_id FK
        uuid entity_id FK
        uuid financial_period_id FK
        text flag_type
        text severity
        text status
        text description
        uuid source_document_id FK
        integer page_number
        jsonb bounding_box
        text extractor_model
        numeric confidence
        jsonb raw_blob
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    memos {
        uuid id PK
        uuid borrower_id FK
        uuid entity_id FK
        uuid financial_period_id FK
        text status
        text body_markdown
        text generated_model
        timestamptz generated_at
        timestamptz created_at
        timestamptz updated_at
        timestamptz deleted_at
    }

    memo_citations {
        uuid id PK
        uuid memo_id FK
        uuid line_item_id FK
        uuid ratio_id FK
        uuid reconciliation_id FK
        text claim_text
        uuid source_document_id FK
        integer page_number
        jsonb bounding_box
        text extractor_model
        numeric confidence
        jsonb raw_blob
        timestamptz created_at
        timestamptz updated_at
    }

    borrowers ||--o{ owners : "has"
    borrowers ||--o{ entities : "operates"
    borrowers ||--o{ documents : "submits"
    borrowers ||--o{ memos : "receives"
    entities ||--o{ financial_periods : "has"
    entities ||--o{ ratios : "has"
    entities ||--o{ reconciliations : "has"
    entities ||--o{ exception_flags : "has"
    entities ||--o{ memos : "for"
    financial_periods ||--o{ documents : "covers"
    financial_periods ||--o{ line_items : "in"
    financial_periods ||--o{ ratios : "for"
    financial_periods ||--o{ reconciliations : "for"
    financial_periods ||--o{ exception_flags : "for"
    financial_periods ||--o{ memos : "summarizes"
    documents ||--o| tax_returns : "is-a"
    documents ||--o| bank_statements : "is-a"
    documents ||--o{ line_items : "contains"
    line_items ||--o{ memo_citations : "cited-by"
    ratios ||--o{ memo_citations : "cited-by"
    reconciliations ||--o{ exception_flags : "generates"
    reconciliations ||--o{ memo_citations : "cited-by"
    memos ||--o{ memo_citations : "has"
```

---

## Table descriptions

**borrowers** — The legal loan applicant. Root entity for the whole ontology. Every document,
memo, and owner anchors here. `ein` (EIN, XX-XXXXXXX) is the primary external identifier used
for IRS cross-references. One borrower can control multiple operating entities.

**owners** — Personal guarantors and beneficial owners of a borrower. v1 scope is minimal
(name, ownership %, credit score, SSN last 4). Expanded in Phase 3 to hold personal tax
return extractions and owner-DTI inputs. Cascades with borrower: deleting a borrower removes
all owner rows.

**entities** — The operating business(es) controlled by a borrower. One borrower may file
separate tax returns for multiple entities (e.g. a holding company + an operating LLC). `naics_code`
enables industry-sector comparisons in the ratio engine.

**financial_periods** — A named time window attached to an entity. Supports overlapping ranges
(no UNIQUE constraint) so annual, quarterly, and trailing-12-month periods can coexist for the
same entity. The `label` column holds human-readable slugs ("FY2023", "TTM-Dec-2023"). Cascades
with entity.

**documents** — Abstract parent record for any uploaded source file. Holds the file-level
metadata (filename, SHA-256 hash, page count) and the borrower / entity / period context.
The `doc_type` discriminator mirrors the subtype so queries can filter without joining.
ON DELETE RESTRICT on all FKs: a document is evidence and must not disappear silently.

**tax_returns** — Table-per-subtype extension of documents. Carries 1120/1120S/1065 metadata.
PK = FK to documents.id (shared-PK pattern). Cascades with its base document row.

**bank_statements** — Table-per-subtype extension of documents. Carries bank + account context.
`statement_month` is stored as the first day of the month for easy date-range arithmetic.
Cascades with its base document row.

**line_items** — The atomic extracted financial facts (revenue lines, expense lines, deposit
totals, withdrawal totals). Every row carries the full provenance block. `document_id` is the
functional FK (which document this item belongs to); `source_document_id` in the provenance
block is the evidentiary FK (which document page it was read from — typically the same, but
kept separate so the schema survives multi-document extractions).

**ratios** — Computed ratios (DSCR, current ratio, debt service coverage, working capital,
owner DTI). `numerator_snapshot` and `denominator_snapshot` store the line_item IDs + values
used in the calculation as JSONB, so the ratio can be re-derived or audited without re-running
the pipeline. Provenance columns are nullable because ratios are computed, not page-extracted.

**reconciliations** — Cross-document consistency checks. v1 supports three types:
`revenue_cross_check` (tax vs. tax line comparison), `deposit_to_revenue` (bank deposits vs.
reported revenue), `expense_to_payment` (reported expenses vs. bank outflows). `delta_amount`
records the signed discrepancy magnitude. ON DELETE RESTRICT: a reconciliation finding is
evidence and should not cascade-delete silently.

**exception_flags** — Surfaced inconsistencies or threshold breaches. A flag is usually
generated by a reconciliation (`reconciliation_id` FK), but can also be raised directly
(e.g. a credit-score threshold breach). Severity and status columns drive the underwriter
triage UI. Cascades from reconciliation: if the reconciliation row is deleted, its flags go too.

**memos** — The generated credit memo. `body_markdown` holds the full memo text; `generated_model`
records which LLM version produced it. ON DELETE RESTRICT on all FKs: a memo is a deliverable
and must not be silently orphaned.

**memo_citations** — Each row anchors one claim in the memo body to its source evidence.
At least one of `line_item_id`, `ratio_id`, or `reconciliation_id` should be non-null.
Carries its own provenance block (the specific page/bbox the cited value appeared on).
Cascades with memo: deleting a memo removes all its citation rows.
