-- AEGIS Ontology DDL — Postgres 16
-- Idempotent: CREATE TABLE IF NOT EXISTS + CREATE INDEX IF NOT EXISTS
-- Apply via: make schema-apply

BEGIN;

-- ──────────────────────────────────────────────────────────────────────────────
-- CORE ENTITIES
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS borrowers (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    legal_name          TEXT        NOT NULL,
    dba_name            TEXT,
    ein                 CHAR(10),                   -- XX-XXXXXXX
    entity_type         TEXT        NOT NULL,        -- LLC | S-Corp | C-Corp | Partnership | Sole Prop
    state_of_formation  CHAR(2),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);

-- owners: personal guarantors / beneficial owners of a borrower
-- Expanded to a full table in Phase 3 (DTI, personal financials); minimal for v1.
CREATE TABLE IF NOT EXISTS owners (
    id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    borrower_id     UUID        NOT NULL REFERENCES borrowers(id) ON DELETE CASCADE,
    full_name       TEXT        NOT NULL,
    ownership_pct   NUMERIC(5,2) NOT NULL,          -- 0.00–100.00
    ssn_last4       CHAR(4),
    credit_score    SMALLINT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at      TIMESTAMPTZ
);

-- entities: operating businesses (a borrower may have multiple operating entities)
CREATE TABLE IF NOT EXISTS entities (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    borrower_id         UUID        NOT NULL REFERENCES borrowers(id) ON DELETE CASCADE,
    legal_name          TEXT        NOT NULL,
    dba_name            TEXT,
    ein                 CHAR(10),
    entity_type         TEXT        NOT NULL,
    state_of_formation  CHAR(2),
    naics_code          CHAR(6),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);

-- financial_periods: no UNIQUE constraint on (entity_id, start_date, end_date) — overlapping
-- ranges are valid (e.g. trailing-12-month windows overlapping quarterly periods).
-- period_type: annual | quarterly | trailing12 | custom
CREATE TABLE IF NOT EXISTS financial_periods (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id   UUID        NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    period_type TEXT        NOT NULL,
    start_date  DATE        NOT NULL,
    end_date    DATE        NOT NULL,
    label       TEXT,                               -- human label: "FY2023", "Q3-2023", "TTM-Dec-2023"
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at  TIMESTAMPTZ,
    CONSTRAINT financial_periods_dates_check CHECK (end_date >= start_date)
);

-- ──────────────────────────────────────────────────────────────────────────────
-- DOCUMENTS  (base table + table-per-subtype for tax_returns / bank_statements)
-- Inheritance model: TPT (table-per-subtype). See ADR-0011 §a.
-- doc_type discriminator retained on base table for fast filtering without joins.
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS documents (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    borrower_id         UUID        NOT NULL REFERENCES borrowers(id) ON DELETE RESTRICT,
    entity_id           UUID        REFERENCES entities(id) ON DELETE RESTRICT,
    financial_period_id UUID        REFERENCES financial_periods(id) ON DELETE RESTRICT,
    doc_type            TEXT        NOT NULL,       -- tax_return | bank_statement
    filename            TEXT        NOT NULL,
    file_hash           TEXT,                       -- SHA-256 of the original file bytes
    page_count          INTEGER,
    uploaded_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);

-- Shared-PK pattern: tax_returns.id IS the documents.id for this subtype row.
-- ON DELETE CASCADE: removing the base document removes the subtype row.
CREATE TABLE IF NOT EXISTS tax_returns (
    id              UUID    PRIMARY KEY REFERENCES documents(id) ON DELETE CASCADE,
    form_type       TEXT    NOT NULL,               -- 1120 | 1120S | 1065
    tax_year        SMALLINT NOT NULL,
    fiscal_year_end DATE,
    preparer_name   TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS bank_statements (
    id                      UUID    PRIMARY KEY REFERENCES documents(id) ON DELETE CASCADE,
    bank_name               TEXT    NOT NULL,
    account_number_last4    CHAR(4),
    statement_month         DATE    NOT NULL,       -- first day of month (e.g. 2023-01-01)
    account_type            TEXT,                   -- checking | savings | money_market
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- PROVENANCE COLUMNS — repeated inline on every fact-bearing table
-- Shape: (source_document_id, page_number, bounding_box, extractor_model,
--          confidence, raw_blob). See ADR-0011 §b.
--
-- Cascade choice: RESTRICT on source_document_id — losing a document should
-- never silently delete the evidence record that cites it.
-- ──────────────────────────────────────────────────────────────────────────────

-- ──────────────────────────────────────────────────────────────────────────────
-- LINE ITEMS
-- category: revenue | expense | deposit | withdrawal | other
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS line_items (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id         UUID         NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    financial_period_id UUID         REFERENCES financial_periods(id) ON DELETE RESTRICT,
    category            TEXT         NOT NULL,
    subcategory         TEXT,
    label               TEXT         NOT NULL,
    amount              NUMERIC(18,2) NOT NULL,
    currency            CHAR(3)      NOT NULL DEFAULT 'USD',
    is_annualized       BOOLEAN      NOT NULL DEFAULT FALSE,
    -- provenance
    source_document_id  UUID         REFERENCES documents(id) ON DELETE RESTRICT,
    page_number         INTEGER,
    bounding_box        JSONB,                      -- {x0, y0, x1, y1, units}
    extractor_model     TEXT,
    confidence          NUMERIC(4,3) CHECK (confidence BETWEEN 0 AND 1),
    raw_blob            JSONB,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);

-- ──────────────────────────────────────────────────────────────────────────────
-- RATIOS
-- ratio_type: dscr | current_ratio | debt_service | working_capital | owner_dti
-- Provenance columns are nullable here: ratios are computed, not page-extracted.
-- numerator_snapshot / denominator_snapshot carry the line_item IDs + amounts
-- used in the calculation so the ratio can be re-derived without re-running.
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS ratios (
    id                      UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id               UUID         NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
    financial_period_id     UUID         NOT NULL REFERENCES financial_periods(id) ON DELETE RESTRICT,
    ratio_type              TEXT         NOT NULL,
    value                   NUMERIC(10,4),
    numerator_snapshot      JSONB,
    denominator_snapshot    JSONB,
    -- provenance (nullable for computed ratios)
    source_document_id      UUID         REFERENCES documents(id) ON DELETE RESTRICT,
    page_number             INTEGER,
    bounding_box            JSONB,
    extractor_model         TEXT,
    confidence              NUMERIC(4,3) CHECK (confidence BETWEEN 0 AND 1),
    raw_blob                JSONB,
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at              TIMESTAMPTZ
);

-- ──────────────────────────────────────────────────────────────────────────────
-- RECONCILIATIONS
-- recon_type: revenue_cross_check | deposit_to_revenue | expense_to_payment
-- status:     pass | fail | review
-- delta_amount: signed magnitude of discrepancy (positive = bank > tax, negative = opposite)
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS reconciliations (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id           UUID         NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
    financial_period_id UUID         NOT NULL REFERENCES financial_periods(id) ON DELETE RESTRICT,
    recon_type          TEXT         NOT NULL,
    status              TEXT         NOT NULL DEFAULT 'review',
    finding_summary     TEXT,
    delta_amount        NUMERIC(18,2),
    currency            CHAR(3)      NOT NULL DEFAULT 'USD',
    -- provenance
    source_document_id  UUID         REFERENCES documents(id) ON DELETE RESTRICT,
    page_number         INTEGER,
    bounding_box        JSONB,
    extractor_model     TEXT,
    confidence          NUMERIC(4,3) CHECK (confidence BETWEEN 0 AND 1),
    raw_blob            JSONB,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);

-- ──────────────────────────────────────────────────────────────────────────────
-- EXCEPTION FLAGS
-- severity: low | medium | high | critical
-- status:   open | resolved | waived
-- reconciliation_id nullable: a flag can be raised outside a reconciliation
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS exception_flags (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    reconciliation_id   UUID         REFERENCES reconciliations(id) ON DELETE CASCADE,
    entity_id           UUID         NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
    financial_period_id UUID         NOT NULL REFERENCES financial_periods(id) ON DELETE RESTRICT,
    flag_type           TEXT         NOT NULL,
    severity            TEXT         NOT NULL DEFAULT 'medium',
    status              TEXT         NOT NULL DEFAULT 'open',
    description         TEXT,
    -- provenance
    source_document_id  UUID         REFERENCES documents(id) ON DELETE RESTRICT,
    page_number         INTEGER,
    bounding_box        JSONB,
    extractor_model     TEXT,
    confidence          NUMERIC(4,3) CHECK (confidence BETWEEN 0 AND 1),
    raw_blob            JSONB,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);

-- ──────────────────────────────────────────────────────────────────────────────
-- MEMOS + CITATIONS
-- status: draft | review | final
-- memo_citations: each row anchors one claim in the memo body to its source evidence.
-- At least one of line_item_id / ratio_id / reconciliation_id should be non-null.
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS memos (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    borrower_id         UUID        NOT NULL REFERENCES borrowers(id) ON DELETE RESTRICT,
    entity_id           UUID        NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
    financial_period_id UUID        NOT NULL REFERENCES financial_periods(id) ON DELETE RESTRICT,
    status              TEXT        NOT NULL DEFAULT 'draft',
    body_markdown       TEXT,
    generated_model     TEXT,
    generated_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS memo_citations (
    id                  UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    memo_id             UUID         NOT NULL REFERENCES memos(id) ON DELETE CASCADE,
    line_item_id        UUID         REFERENCES line_items(id) ON DELETE RESTRICT,
    ratio_id            UUID         REFERENCES ratios(id) ON DELETE RESTRICT,
    reconciliation_id   UUID         REFERENCES reconciliations(id) ON DELETE RESTRICT,
    claim_text          TEXT         NOT NULL,
    -- provenance
    source_document_id  UUID         REFERENCES documents(id) ON DELETE RESTRICT,
    page_number         INTEGER,
    bounding_box        JSONB,
    extractor_model     TEXT,
    confidence          NUMERIC(4,3) CHECK (confidence BETWEEN 0 AND 1),
    raw_blob            JSONB,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ──────────────────────────────────────────────────────────────────────────────
-- INDEXES
-- ──────────────────────────────────────────────────────────────────────────────

-- borrower lookups
CREATE INDEX IF NOT EXISTS idx_borrowers_ein
    ON borrowers(ein) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_entities_borrower
    ON entities(borrower_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_owners_borrower
    ON owners(borrower_id) WHERE deleted_at IS NULL;

-- document → line_items (hot path for extraction review)
CREATE INDEX IF NOT EXISTS idx_documents_borrower
    ON documents(borrower_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_documents_entity
    ON documents(entity_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_documents_period
    ON documents(financial_period_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_documents_doctype
    ON documents(doc_type);
CREATE INDEX IF NOT EXISTS idx_line_items_document
    ON line_items(document_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_line_items_period
    ON line_items(financial_period_id) WHERE deleted_at IS NULL;

-- exception_flags by severity + status (underwriter triage view)
CREATE INDEX IF NOT EXISTS idx_exception_flags_severity_status
    ON exception_flags(severity, status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_exception_flags_entity
    ON exception_flags(entity_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_exception_flags_recon
    ON exception_flags(reconciliation_id) WHERE deleted_at IS NULL;

-- memo → citations
CREATE INDEX IF NOT EXISTS idx_memo_citations_memo
    ON memo_citations(memo_id);
CREATE INDEX IF NOT EXISTS idx_memo_citations_line_item
    ON memo_citations(line_item_id);

-- ratios + reconciliations (analytical queries)
CREATE INDEX IF NOT EXISTS idx_ratios_entity_period
    ON ratios(entity_id, financial_period_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_reconciliations_entity_period
    ON reconciliations(entity_id, financial_period_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_reconciliations_status
    ON reconciliations(status) WHERE deleted_at IS NULL;

-- financial_periods range queries
CREATE INDEX IF NOT EXISTS idx_financial_periods_entity_dates
    ON financial_periods(entity_id, start_date, end_date) WHERE deleted_at IS NULL;

COMMIT;
