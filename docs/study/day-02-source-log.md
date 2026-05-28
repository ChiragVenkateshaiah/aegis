# Day 02 — Source Access Log

**Date:** 2026-05-21
**Reconstructed:** 2026-05-28

---

| # | Source | URL / Reference | Access outcome | Notes |
|---|--------|----------------|----------------|-------|
| 1 | OCC Comptroller's Handbook — Commercial Loans | occ.gov/publications-and-resources/publications/comptrollers-handbook/files/commercial-loans/... | Binary PDF — WebFetch returned raw binary, not parseable text | Studied via structure/section headings visible in PDF metadata; content reconstructed from domain knowledge of OCC exam standards |
| 2 | OCC Comptroller's Handbook — Rating Credit Risk | occ.gov/publications-and-resources/publications/comptrollers-handbook/files/rating-credit-risk/... | Binary PDF — same issue as above | Key content (BRR/FRR, interagency classification definitions) reconstructed from examiner guidance |
| 3 | FDIC Risk Management Manual of Examination Policies — Chapter 11 (Loans) | fdic.gov/regulations/safety/manual/section3-2.html (and ch11.pdf) | 403 Forbidden — direct PDF link returned 403 | HTML version of the manual was partially accessible; ch11.pdf blocked |
| 4 | RMA Annual Statement Studies | rmahq.org/annual-statement-studies | Subscription-only — no access without RMA membership | Industry financial benchmarks (advance rates, ratio norms by NAICS) not retrievable; will need RMA membership or use of FFIEC data as proxy |
| 5 | FFIEC Commercial Bank Examination Manual | ffiec.gov/examination/commercial_bank/default.htm | Accessible (HTML) | Provided supplemental confirmation of interagency classification definitions and dual risk rating expectations |

---

## Findings summary

- **OCC PDFs:** Binary format returned by WebFetch; content not parseable as text. All OCC handbook content in the study notes was derived from examiner knowledge of the OCC standards, not direct text extraction.
- **FDIC ch11:** Direct PDF blocked (403). Partial HTML access available but incomplete.
- **RMA:** Subscription required. RMA Annual Statement Studies are the industry standard for financial ratio benchmarks by NAICS code — the absence of RMA access is a gap for Phase 3 ratio analysis.
- **FFIEC:** Publicly accessible HTML; useful for classification and rating definitions.

## Implication for AEGIS

When the extraction pipeline (Phase 2) handles reference document ingestion, OCC/FDIC PDFs will need to be handled as binary documents requiring OCR preprocessing — they cannot be fed directly to `WebFetch` or simple text extraction. This is a known constraint to document before Phase 2 design.
