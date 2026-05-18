# AEGIS — Makefile
# Requires: psql, DATABASE_URL env var pointing at a Postgres 16 instance.
# Example:
#   export DATABASE_URL=postgres://aegis:aegis@localhost:5432/aegis
#   make schema-apply

.PHONY: schema-apply schema-verify help

help:
	@echo "Available targets:"
	@echo "  schema-apply   Apply DDL + seed to DATABASE_URL"
	@echo "  schema-verify  Run acceptance checks against DATABASE_URL"

schema-apply:
	@if [ -z "$$DATABASE_URL" ]; then \
		echo "ERROR: DATABASE_URL is not set"; exit 1; \
	fi
	@echo "Applying DDL..."
	psql "$$DATABASE_URL" -v ON_ERROR_STOP=1 -f data/schemas/ontology.sql
	@echo "Applying seed..."
	psql "$$DATABASE_URL" -v ON_ERROR_STOP=1 -f data/seeds/seed_minimal.sql
	@echo "Done. Run 'make schema-verify' to check."

schema-verify:
	@bash data/schemas/check.sh
