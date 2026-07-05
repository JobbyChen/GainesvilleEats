#!/usr/bin/env python3
"""
Compute nearby restaurants using the Haversine formula in Python and write results to a SQLite table.
Usage:
    python scripts/compute_nearby.py DB_PATH UF_LAT UF_LON RADIUS_MILES
Defaults (if not provided): UF_LAT=29.651632, UF_LON=-82.324826, RADIUS_MILES=1.0
The script writes a table `nearby_restaurants(restaurant_id INTEGER PRIMARY KEY, name TEXT, distance_miles REAL)`
which queries/03_local_spots_near_uf.sql expects.
"""
import sys
import sqlite3
import math


def haversine_miles(lat1, lon1, lat2, lon2):
    # Earth radius in miles
    R = 3959.0
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi/2.0)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2.0)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


def compute_nearby(db_path, uf_lat=29.651632, uf_lon=-82.324826, radius_miles=1.0):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    # Read restaurants with coordinates
    cur.execute("SELECT id, name, latitude, longitude FROM restaurants WHERE latitude IS NOT NULL AND longitude IS NOT NULL")
    rows = cur.fetchall()
    results = []
    for rid, name, lat, lon in rows:
        try:
            lat_f = float(lat)
            lon_f = float(lon)
        except Exception:
            continue
        dist = haversine_miles(uf_lat, uf_lon, lat_f, lon_f)
        if dist <= radius_miles:
            results.append((rid, name, dist))
    # Replace nearby_restaurants table
    cur.execute("DROP TABLE IF EXISTS nearby_restaurants")
    cur.execute("CREATE TABLE nearby_restaurants (restaurant_id INTEGER PRIMARY KEY, name TEXT, distance_miles REAL)")
    cur.executemany("INSERT INTO nearby_restaurants(restaurant_id, name, distance_miles) VALUES (?, ?, ?)",
                    [(int(r[0]), r[1], float(r[2])) for r in results])
    conn.commit()
    conn.close()
    print(f"Wrote {len(results)} nearby restaurants to table 'nearby_restaurants' (radius {radius_miles} mi)")


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/compute_nearby.py DB_PATH [UF_LAT UF_LON RADIUS_MILES]")
        sys.exit(2)
    db_path = sys.argv[1]
    if len(sys.argv) >= 5:
        uf_lat = float(sys.argv[2])
        uf_lon = float(sys.argv[3])
        radius_miles = float(sys.argv[4])
    else:
        uf_lat, uf_lon, radius_miles = 29.651632, -82.324826, 1.0
    compute_nearby(db_path, uf_lat, uf_lon, radius_miles)

if __name__ == '__main__':
    main()
