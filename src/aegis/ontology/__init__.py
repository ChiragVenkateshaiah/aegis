"""
aegis.ontology — Ontology layer for the AEGIS credit memo co-pilot.

This package will hold:
  - SQLAlchemy ORM models mirroring data/schemas/ontology.sql (Phase 2)
  - Pydantic schemas for API boundary validation (Phase 2)
  - Query helpers for common joins (borrower → entity → period → documents) (Phase 3)
  - Provenance utilities: building and validating the evidence block shape (Phase 3)

For now the package is a marker stub. The DDL lives in data/schemas/ontology.sql.
"""
