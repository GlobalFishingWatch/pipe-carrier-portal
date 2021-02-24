# -*- coding: utf-8 -*-
import sys
import json
import csv
import re

from pipe_carrier_portal.downloadables.fields import field_names

csv_file = sys.argv[1]

def record_to_csv_dict(record):
    event_vessels = json.loads(record["event_vessels"])

    main_vessel = event_vessels[0]

    info = json.loads(record["event_info"])

    return {
        "id": record["event_id"],
        "type": "loitering",
        "start": record["event_start"],
        "end": record["event_end"],
        "lat": record["lat_mean"],
        "lon": record["lon_mean"],
        "vessel.id": main_vessel["id"],
        "vessel.type": "carrier",
        "vessel.mmsi": main_vessel["ssvid"],
        "vessel.name": main_vessel["name"],
        "vessel.flag": main_vessel["flag"],
        "vessel.origin_port.country": info["origin_port"]["iso"],
        "vessel.origin_port.name": info["origin_port"]["label"],
        "vessel.destination_port.country": info["destination_port"]["iso"],
        "vessel.destination_port.name": info["destination_port"]["label"],
        "median_speed_knots": info["median_speed_knots"],
        "elevation_m": info["elevation_m"],
        "distance_from_shore_m": info["distance_from_shore_m"],
        "distance_from_port_m": info["distance_from_port_m"],
        "regions.rfmo": "|".join(info["regions"]["rfmo"] or []),
        "loitering.total_distance_km": info["total_distance_km"],
        "loitering.loitering_hours": info["loitering_hours"],
    }


with open(csv_file, "w", newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=field_names)
    writer.writeheader()

    for line in sys.stdin:
        record = json.loads(line)
        csv_dict = record_to_csv_dict(record)

        if csv_dict:
            try:
                writer.writerow(csv_dict)
            except:
                print(f"Unable to convert record to csv at {record}")
                raise
