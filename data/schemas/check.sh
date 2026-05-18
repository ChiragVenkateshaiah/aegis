#!/usr/bin/env bash
# Acceptance check for AEGIS ontology DDL + seed.
# Usage: DATABASE_URL=postgres://... bash data/schemas/check.sh
# Exits non-zero on any failure.

set -euo pipefail

if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "ERROR: DATABASE_URL is not set" >&2
    exit 1
fi

PSQL="psql ${DATABASE_URL} -v ON_ERROR_STOP=1 -t -A -q"

fail() { echo "FAIL: $1" >&2; exit 1; }
pass() { printf "PASS  %s\n" "$1"; }

echo ""
echo "=== AEGIS schema acceptance check ==="
echo ""

# ── 1. Expected tables exist ──────────────────────────────────────────────────
EXPECTED_TABLES=(
    borrowers owners entities financial_periods
    documents tax_returns bank_statements
    line_items ratios reconciliations exception_flags
    memos memo_citations
)

for tbl in "${EXPECTED_TABLES[@]}"; do
    count=$(${PSQL} -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='${tbl}';")
    [[ "${count}" -eq 1 ]] || fail "Table '${tbl}' not found in public schema"
    pass "table exists: ${tbl}"
done

echo ""

# ── 2. Seed row counts ────────────────────────────────────────────────────────
check_count() {
    local label="$1" query="$2" expected="$3"
    actual=$(${PSQL} -c "${query}")
    [[ "${actual}" -eq "${expected}" ]] || fail "${label}: expected ${expected} rows, got ${actual}"
    pass "${label}: ${expected} row(s)"
}

check_count "borrowers"          "SELECT COUNT(*) FROM borrowers;"          1
check_count "owners"             "SELECT COUNT(*) FROM owners;"             1
check_count "entities"           "SELECT COUNT(*) FROM entities;"           1
check_count "financial_periods"  "SELECT COUNT(*) FROM financial_periods;"  1
check_count "documents"          "SELECT COUNT(*) FROM documents;"          2
check_count "tax_returns"        "SELECT COUNT(*) FROM tax_returns;"        1
check_count "bank_statements"    "SELECT COUNT(*) FROM bank_statements;"    1
check_count "line_items"         "SELECT COUNT(*) FROM line_items;"         5
check_count "ratios"             "SELECT COUNT(*) FROM ratios;"             1
check_count "reconciliations"    "SELECT COUNT(*) FROM reconciliations;"    1
check_count "exception_flags"    "SELECT COUNT(*) FROM exception_flags;"    1
check_count "memos"              "SELECT COUNT(*) FROM memos;"              1
check_count "memo_citations"     "SELECT COUNT(*) FROM memo_citations;"     2

echo ""

# ── 3. Sanity join: memo → memo_citations → source_document (expect 2 rows) ──
JOIN_QUERY="
SELECT COUNT(*)
FROM memo_citations mc
JOIN memos m ON m.id = mc.memo_id
LEFT JOIN line_items li ON li.id = mc.line_item_id
LEFT JOIN ratios r ON r.id = mc.ratio_id
LEFT JOIN documents d ON d.id = mc.source_document_id
WHERE m.id = 'aaaaaaaa-0011-0011-0011-000000000001';
"
join_count=$(${PSQL} -c "${JOIN_QUERY}")
[[ "${join_count}" -eq 2 ]] || fail "memo→citations join: expected 2 rows, got ${join_count}"
pass "memo→citations join: 2 rows"

echo ""
echo "=== All checks passed ==="
echo ""

# ── 4. Print \dt summary for the operator log ─────────────────────────────────
echo "Table listing (psql \\dt):"
psql "${DATABASE_URL}" -c "\dt" 2>/dev/null || true
