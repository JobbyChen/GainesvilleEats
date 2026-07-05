# Gainesville Budget Eats — run locally with SQLite

Overview
--------
This repository contains CSV data, a database schema, SQL queries, and helper scripts to analyze budget-friendly restaurants in Gainesville, FL.

Goal
----
Make it easy to create a local SQLite database from the CSV files, run the SQL queries, and export results.

Prerequisites
-------------
- Python 3.8+
- pip
- sqlite3 (CLI)
- Optional: virtualenv, pandas

Project layout
--------------
- README.md
- requirements.txt
- data/
  - restaurants.csv
  - menu_items.csv
  - reviews.csv
- database/
  - schema.sql
  - load_data.sql (optional)
- queries/
  - 01_cheapest_restaurants.sql
  - 02_best_budget_by_cuisine.sql
  - 03_local_spots_near_uf.sql
  - 04_best_value_restaurants.sql
  - 05_family_owned_options.sql
- scripts/
  - scrape_restaurants.py
  - clean_data.py
  - load_csvs_into_sqlite.py (helper)
- run_all.sh (convenience script)
- db/ (created at runtime)
- outputs/ (created at runtime)

Quick start (recommended)
-------------------------
1. Create a virtualenv and install deps (optional but recommended):
   python -m venv .venv
   source .venv/bin/activate   # macOS / Linux
   .venv\\Scripts\\activate    # Windows
   pip install -r requirements.txt

2. Create the database directory and SQLite DB:
   mkdir -p db outputs
   sqlite3 db/gainesville_eats.db ".databases"

3. Create schema:
   sqlite3 db/gainesville_eats.db ".read database/schema.sql"

4. Import CSVs (recommended: use the Python helper which handles headers and dtype):
   python scripts/load_csvs_into_sqlite.py db/gainesville_eats.db data/

   The helper uses pandas and will create the restaurants, menu_items, and reviews tables (if they don't exist) and import CSVs safely.

5. Run queries and export to CSV:
   ./run_all.sh

   This script will run each queries/*.sql against db/gainesville_eats.db and write outputs/*.csv.

Notes and troubleshooting
-------------------------
- Schema: README assumes table names and columns:
  restaurants(id, name, cuisine, address, neighborhood, latitude, longitude, family_owned)
  menu_items(id, restaurant_id, name, price)
  reviews(id, restaurant_id, rating, review_text, review_date)

  If your schema differs, either adjust the schema.sql or update the queries.

- SQLite trig functions: some queries use radians(), cos(), sin(), acos(); older or minimal SQLite builds may not provide these. If you see errors running queries/03_local_spots_near_uf.sql, use the bounding-box fallback included in that file (a comment explains how to switch).

Sample output (what each query answers)
---------------------------------------

01_cheapest_restaurants.sql
- What: restaurants with the lowest average menu price.
- Key columns: restaurant_id, name, avg_price, menu_item_count
- Example row:
  12 | Corner Deli | 4.50 | 24

02_best_budget_by_cuisine.sql
- What: best budget restaurant per cuisine combining low price and good rating.
- Key columns: cuisine, restaurant_id, name, avg_price, avg_rating
- Example row:
  Mexican | 05 | Taco Town | 5.10 | 4.3

03_local_spots_near_uf.sql
- What: budget-friendly restaurants within a radius (default 1 mile) of UF coordinates.
- Key columns: restaurant_id, name, distance_miles, avg_price
- Example row:
  37 | Budget Bites | 0.2 | 4.75

04_best_value_restaurants.sql
- What: ranked by avg_rating / avg_price (value score).
- Key columns: restaurant_id, name, value_score, avg_rating, avg_price
- Example row:
  22 | Noodle House | 0.71 | 4.4 | 6.2

05_family_owned_options.sql
- What: family-owned restaurants ordered by avg_price (cheapest first).
- Key columns: restaurant_id, name, avg_price, avg_rating, neighborhood
- Example row:
  44 | Grandma's Diner | 6.00 | 4.6 | Downtown

How to run a single query manually
----------------------------------
sqlite3 -header -csv db/gainesville_eats.db ".read queries/01_cheapest_restaurants.sql" > outputs/01_cheapest_restaurants.csv

Or:
sqlite3 -header -csv db/gainesville_eats.db "SELECT * FROM ( $(cat queries/01_cheapest_restaurants.sql) );" > outputs/01.csv

(Using the provided run_all.sh is simpler.)

If you want me to push the branch and files directly, reply “Please push” and I’ll proceed.
