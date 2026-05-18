-- AEGIS Minimal Seed — one fake borrower end-to-end
-- Entity: Acme Restaurant Group LLC (obviously fake)
-- Requires ontology.sql to have been applied first.
-- Run via: make schema-apply (which applies DDL then this seed)

BEGIN;

-- ── Borrower ──────────────────────────────────────────────────────────────────
INSERT INTO borrowers (id, legal_name, dba_name, ein, entity_type, state_of_formation)
VALUES (
    'aaaaaaaa-0001-0001-0001-000000000001',
    'Acme Restaurant Group LLC',
    'Acme Burgers',
    '12-3456789',
    'LLC',
    'CA'
) ON CONFLICT (id) DO NOTHING;

-- ── Owner ─────────────────────────────────────────────────────────────────────
INSERT INTO owners (id, borrower_id, full_name, ownership_pct, ssn_last4, credit_score)
VALUES (
    'aaaaaaaa-0002-0002-0002-000000000001',
    'aaaaaaaa-0001-0001-0001-000000000001',
    'Jane Doe',
    100.00,
    '4321',
    720
) ON CONFLICT (id) DO NOTHING;

-- ── Entity ────────────────────────────────────────────────────────────────────
INSERT INTO entities (id, borrower_id, legal_name, dba_name, ein, entity_type, state_of_formation, naics_code)
VALUES (
    'aaaaaaaa-0003-0003-0003-000000000001',
    'aaaaaaaa-0001-0001-0001-000000000001',
    'Acme Restaurant Group LLC',
    'Acme Burgers',
    '12-3456789',
    'LLC',
    'CA',
    '722511'    -- Full-Service Restaurants
) ON CONFLICT (id) DO NOTHING;

-- ── Financial Period (FY2023) ─────────────────────────────────────────────────
INSERT INTO financial_periods (id, entity_id, period_type, start_date, end_date, label)
VALUES (
    'aaaaaaaa-0004-0004-0004-000000000001',
    'aaaaaaaa-0003-0003-0003-000000000001',
    'annual',
    '2023-01-01',
    '2023-12-31',
    'FY2023'
) ON CONFLICT (id) DO NOTHING;

-- ── Documents ─────────────────────────────────────────────────────────────────

-- Tax return (1120S for FY2023)
INSERT INTO documents (id, borrower_id, entity_id, financial_period_id, doc_type, filename, file_hash, page_count)
VALUES (
    'aaaaaaaa-0005-0005-0005-000000000001',
    'aaaaaaaa-0001-0001-0001-000000000001',
    'aaaaaaaa-0003-0003-0003-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'tax_return',
    'acme-1120s-2023.pdf',
    'abc123fakehash000000000000000000000000000000000000000000000000000',
    42
) ON CONFLICT (id) DO NOTHING;

INSERT INTO tax_returns (id, form_type, tax_year, fiscal_year_end, preparer_name)
VALUES (
    'aaaaaaaa-0005-0005-0005-000000000001',
    '1120S',
    2023,
    '2023-12-31',
    'Ace Accounting LLC'
) ON CONFLICT (id) DO NOTHING;

-- Bank statement (Chase checking, January 2023)
INSERT INTO documents (id, borrower_id, entity_id, financial_period_id, doc_type, filename, file_hash, page_count)
VALUES (
    'aaaaaaaa-0006-0006-0006-000000000001',
    'aaaaaaaa-0001-0001-0001-000000000001',
    'aaaaaaaa-0003-0003-0003-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'bank_statement',
    'acme-chase-jan-2023.pdf',
    'def456fakehash000000000000000000000000000000000000000000000000000',
    8
) ON CONFLICT (id) DO NOTHING;

INSERT INTO bank_statements (id, bank_name, account_number_last4, statement_month, account_type)
VALUES (
    'aaaaaaaa-0006-0006-0006-000000000001',
    'Chase Bank',
    '7890',
    '2023-01-01',
    'checking'
) ON CONFLICT (id) DO NOTHING;

-- ── Line Items (5 total) ──────────────────────────────────────────────────────

-- From tax return (3 items)
INSERT INTO line_items (
    id, document_id, financial_period_id,
    category, label, amount, currency,
    source_document_id, page_number, bounding_box, extractor_model, confidence, raw_blob
) VALUES
(
    'aaaaaaaa-0007-0007-0007-000000000001',
    'aaaaaaaa-0005-0005-0005-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'revenue', 'Gross receipts', 1200000.00, 'USD',
    'aaaaaaaa-0005-0005-0005-000000000001', 2,
    '{"x0": 100, "y0": 200, "x1": 400, "y1": 220, "units": "pt"}',
    'claude-3-5-sonnet-20241022', 0.970,
    '{"raw_text": "Gross receipts or sales    1,200,000"}'
),
(
    'aaaaaaaa-0007-0007-0007-000000000002',
    'aaaaaaaa-0005-0005-0005-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'expense', 'Cost of goods sold', 480000.00, 'USD',
    'aaaaaaaa-0005-0005-0005-000000000001', 2,
    '{"x0": 100, "y0": 240, "x1": 400, "y1": 260, "units": "pt"}',
    'claude-3-5-sonnet-20241022', 0.950,
    '{"raw_text": "Cost of goods sold         480,000"}'
),
(
    'aaaaaaaa-0007-0007-0007-000000000003',
    'aaaaaaaa-0005-0005-0005-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'expense', 'Total deductions', 750000.00, 'USD',
    'aaaaaaaa-0005-0005-0005-000000000001', 3,
    '{"x0": 100, "y0": 300, "x1": 400, "y1": 320, "units": "pt"}',
    'claude-3-5-sonnet-20241022', 0.930,
    '{"raw_text": "Total deductions           750,000"}'
)
ON CONFLICT (id) DO NOTHING;

-- From bank statement (2 items)
INSERT INTO line_items (
    id, document_id, financial_period_id,
    category, label, amount, currency,
    source_document_id, page_number, bounding_box, extractor_model, confidence, raw_blob
) VALUES
(
    'aaaaaaaa-0007-0007-0007-000000000004',
    'aaaaaaaa-0006-0006-0006-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'deposit', 'Total deposits Jan 2023', 98000.00, 'USD',
    'aaaaaaaa-0006-0006-0006-000000000001', 1,
    NULL,
    'claude-3-5-sonnet-20241022', 0.990,
    '{"raw_text": "Total Deposits  $98,000.00"}'
),
(
    'aaaaaaaa-0007-0007-0007-000000000005',
    'aaaaaaaa-0006-0006-0006-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'withdrawal', 'Total withdrawals Jan 2023', 72000.00, 'USD',
    'aaaaaaaa-0006-0006-0006-000000000001', 1,
    NULL,
    'claude-3-5-sonnet-20241022', 0.990,
    '{"raw_text": "Total Withdrawals  $72,000.00"}'
)
ON CONFLICT (id) DO NOTHING;

-- ── Ratio (DSCR = 1.25x) ─────────────────────────────────────────────────────
-- NOI = $450K / Annual debt service = $360K → DSCR = 1.25
INSERT INTO ratios (
    id, entity_id, financial_period_id,
    ratio_type, value,
    numerator_snapshot, denominator_snapshot,
    source_document_id, extractor_model, confidence, raw_blob
) VALUES (
    'aaaaaaaa-0008-0008-0008-000000000001',
    'aaaaaaaa-0003-0003-0003-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'dscr',
    1.2500,
    '{"noi": 450000, "line_item_ids": ["aaaaaaaa-0007-0007-0007-000000000001", "aaaaaaaa-0007-0007-0007-000000000002"]}',
    '{"annual_debt_service": 360000}',
    'aaaaaaaa-0005-0005-0005-000000000001',
    'aegis-ratio-engine-v0.1',
    0.900,
    '{"formula": "NOI / AnnualDebtService", "noi_derivation": "gross_receipts - cogs"}'
) ON CONFLICT (id) DO NOTHING;

-- ── Reconciliation (deposit_to_revenue — intentional discrepancy) ─────────────
-- Annualized Jan deposits: $98K × 12 = $1.176M vs. $1.2M reported → $24K gap
INSERT INTO reconciliations (
    id, entity_id, financial_period_id,
    recon_type, status,
    finding_summary, delta_amount, currency,
    source_document_id, extractor_model, confidence, raw_blob
) VALUES (
    'aaaaaaaa-0009-0009-0009-000000000001',
    'aaaaaaaa-0003-0003-0003-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'deposit_to_revenue',
    'fail',
    'Annualized January deposits ($1,176,000) are $24,000 below reported gross receipts ($1,200,000). 2% variance; within typical tolerance but warrants clarification.',
    -24000.00,
    'USD',
    'aaaaaaaa-0006-0006-0006-000000000001',
    'aegis-recon-engine-v0.1',
    0.850,
    '{"annualized_deposits": 1176000, "reported_revenue": 1200000, "variance_pct": -2.0}'
) ON CONFLICT (id) DO NOTHING;

-- ── Exception Flag ────────────────────────────────────────────────────────────
INSERT INTO exception_flags (
    id, reconciliation_id, entity_id, financial_period_id,
    flag_type, severity, status, description,
    source_document_id, extractor_model, confidence, raw_blob
) VALUES (
    'aaaaaaaa-0010-0010-0010-000000000001',
    'aaaaaaaa-0009-0009-0009-000000000001',
    'aaaaaaaa-0003-0003-0003-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'revenue_variance',
    'medium',
    'open',
    'Annualized January deposits imply ~$1.18M vs. $1.20M on tax return — 2% gap, within threshold (5%) but warrants borrower clarification.',
    'aaaaaaaa-0006-0006-0006-000000000001',
    'aegis-recon-engine-v0.1',
    0.850,
    '{"threshold_pct": 5.0, "actual_variance_pct": 2.0}'
) ON CONFLICT (id) DO NOTHING;

-- ── Memo ──────────────────────────────────────────────────────────────────────
INSERT INTO memos (
    id, borrower_id, entity_id, financial_period_id,
    status, body_markdown, generated_model, generated_at
) VALUES (
    'aaaaaaaa-0011-0011-0011-000000000001',
    'aaaaaaaa-0001-0001-0001-000000000001',
    'aaaaaaaa-0003-0003-0003-000000000001',
    'aaaaaaaa-0004-0004-0004-000000000001',
    'draft',
    E'# Credit Memo — Acme Restaurant Group LLC\n\n## Summary\nAcme Restaurant Group LLC reported gross revenues of $1,200,000 for FY2023 with a DSCR of 1.25x, indicating adequate debt service coverage.\n\n## Revenue Analysis\nGross receipts of $1,200,000 per Form 1120S (FY2023). Annualized bank deposits of $1,176,000 are within 2% of reported revenue.\n\n## Exceptions\n- Medium: Revenue variance between annualized deposits and reported receipts — borrower clarification recommended.',
    'claude-opus-4-7',
    now()
) ON CONFLICT (id) DO NOTHING;

-- ── Memo Citations (2) ────────────────────────────────────────────────────────
INSERT INTO memo_citations (
    id, memo_id, line_item_id, ratio_id, reconciliation_id,
    claim_text,
    source_document_id, page_number, bounding_box, extractor_model, confidence, raw_blob
) VALUES
(
    'aaaaaaaa-0012-0012-0012-000000000001',
    'aaaaaaaa-0011-0011-0011-000000000001',
    'aaaaaaaa-0007-0007-0007-000000000001',   -- line_item: Gross receipts
    NULL,
    NULL,
    'Gross revenues of $1,200,000 for FY2023',
    'aaaaaaaa-0005-0005-0005-000000000001', 2,
    '{"x0": 100, "y0": 200, "x1": 400, "y1": 220, "units": "pt"}',
    'claude-3-5-sonnet-20241022', 0.970,
    '{"raw_text": "Gross receipts or sales    1,200,000"}'
),
(
    'aaaaaaaa-0012-0012-0012-000000000002',
    'aaaaaaaa-0011-0011-0011-000000000001',
    NULL,
    'aaaaaaaa-0008-0008-0008-000000000001',   -- ratio: DSCR
    NULL,
    'DSCR of 1.25x for FY2023',
    'aaaaaaaa-0005-0005-0005-000000000001', NULL,
    NULL,
    'aegis-ratio-engine-v0.1', 0.900,
    '{"formula": "NOI / AnnualDebtService", "value": 1.25}'
)
ON CONFLICT (id) DO NOTHING;

COMMIT;
