#!/usr/bin/env bash
set -euo pipefail
DB="db/gainesville_eats.db"
mkdir -p db outputs
if [ ! -f "$DB" ]; then
  sqlite3 "$DB" ".databases"
fi
# Apply schema if present
if [ -f database/schema.sql ]; then
  sqlite3 "$DB" ".read database/schema.sql"
fi
# Import CSVs via helper
python3 scripts/load_csvs_into_sqlite.py "$DB" data
# Compute nearby restaurants (UF coords + default 1.0 mile radius)
python3 scripts/compute_nearby.py "$DB" 29.651632 -82.324826 1.0
# Run queries and export CSVs
for q in queries/*.sql; do
  base=$(basename "$q" .sql)
  sqlite3 -header -csv "$DB" ".read $q" > "outputs/${base}.csv"
done

echo "All outputs written to outputs/"
