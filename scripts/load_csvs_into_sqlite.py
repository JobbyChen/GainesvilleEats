#!/usr/bin/env python3
"""
Simple CSV -> SQLite loader using pandas.
Usage:
    python scripts/load_csvs_into_sqlite.py path/to/db.sqlite path/to/data_dir
This script will import restaurants.csv, menu_items.csv, reviews.csv (if present).
"""
import sys
import os
import sqlite3
import pandas as pd


def load_csv(conn, csv_path, table_name, if_exists='replace'):
    print(f"Loading {csv_path} -> {table_name}")
    df = pd.read_csv(csv_path)
    # Ensure column names are lowercase for consistency (optional)
    df.columns = [c.strip() for c in df.columns]
    df.to_sql(table_name, conn, if_exists=if_exists, index=False)


def main():
    if len(sys.argv) != 3:
        print("Usage: python scripts/load_csvs_into_sqlite.py DB_PATH DATA_DIR")
        sys.exit(2)
    db_path = sys.argv[1]
    data_dir = sys.argv[2]
    if not os.path.exists(data_dir):
        print(f"Data directory not found: {data_dir}")
        sys.exit(1)
    conn = sqlite3.connect(db_path)
    try:
        mapping = {
            'restaurants.csv': 'restaurants',
            'menu_items.csv': 'menu_items',
            'reviews.csv': 'reviews',
        }
        for fname, tname in mapping.items():
            fpath = os.path.join(data_dir, fname)
            if os.path.exists(fpath):
                load_csv(conn, fpath, tname, if_exists='replace')
            else:
                print(f"Skipping missing file: {fpath}")
    finally:
        conn.close()
    print("Done.")

if __name__ == '__main__':
    main()
