# -*- coding: utf-8 -*-
import sys
import json
import csv
import re

from pipe_carrier_portal.downloadables.fields import field_names

csv_file = sys.argv[1]

def authorization_status_to_public_status(status):
    if status == "unauthorized":
        return "unknown"
    else:
        return status

def record_to_csv_dict(record):
    event_vessels = json.loads(record["event_vessels"])

    if event_vessels[0]["type"] != "carrier":
        return False

    main_vessel = event_vessels[0]
    main_vessel_authorizations = [auth for auth in main_vessel["authorizations"] if auth["rfmo"] is not None]
    main_vessel_authorized_rfmos = [
        auth["rfmo"]
        for auth in main_vessel_authorizations
        if auth["is_authorized"]
    ]
    main_vessel_unknown_rfmos = [
        auth["rfmo"]
        for auth in main_vessel_authorizations
        if not auth["is_authorized"]
    ]

    other_vessel = event_vessels[1]
    encountered_vessel_authorizations = [auth for auth in other_vessel["authorizations"] if auth["rfmo"] is not None]
    other_vessel_authorized_rfmos = [
        auth["rfmo"]
        for auth in encountered_vessel_authorizations
        if auth["is_authorized"]
    ]
    other_vessel_unknown_rfmos = [
        auth["rfmo"]
        for auth in encountered_vessel_authorizations
        if not auth["is_authorized"]
    ]

    info = json.loads(record["event_info"])

    return {
        "id": record["event_id"],
        "type": "encounter",
        "start": record["event_start"],
        "end": record["event_end"],
        "lat": record["lat_mean"],
        "lon": record["lon_mean"],
        "vessel.id": main_vessel["id"],
        "vessel.type": main_vessel["type"],
        "vessel.mmsi": main_vessel["ssvid"],
        "vessel.name": main_vessel["name"],
        "vessel.flag": main_vessel["flag"],
        "vessel.origin_port.country": main_vessel["origin_port"]["iso"],
        "vessel.origin_port.name": main_vessel["origin_port"]["label"],
        "vessel.destination_port.country": main_vessel["destination_port"]["iso"],
        "vessel.destination_port.name": main_vessel["destination_port"]["label"],
        "vessel.authorizations.authorized": "|".join(main_vessel_authorized_rfmos),
        "vessel.authorizations.unknown": "|".join(main_vessel_unknown_rfmos),
        "median_speed_knots": info["median_speed_knots"],
        "elevation_m": info["elevation_m"],
        "distance_from_shore_m": info["distance_from_shore_m"],
        "distance_from_port_m": info["distance_from_port_m"],
        "regions.eez": "|".join(info["regions"]["eez"] or []),
        "regions.rfmo": "|".join(info["regions"]["rfmo"] or []),
        "encounter.median_distance_km": info["median_distance_km"],
        "encounter.authorization_status": authorization_status_to_public_status(info["authorization_status"]),
        "encounter.encountered_vessel.id": other_vessel["id"],
        "encounter.encountered_vessel.type": other_vessel["type"],
        "encounter.encountered_vessel.mmsi": other_vessel["ssvid"],
        "encounter.encountered_vessel.name": other_vessel["name"],
        "encounter.encountered_vessel.flag": other_vessel["flag"],
        "encounter.encountered_vessel.origin_port.country": other_vessel["origin_port"]["iso"],
        "encounter.encountered_vessel.origin_port.name": other_vessel["origin_port"]["label"],
        "encounter.encountered_vessel.destination_port.country": other_vessel["destination_port"]["iso"],
        "encounter.encountered_vessel.destination_port.name": other_vessel["destination_port"]["label"],
        "encounter.encountered_vessel.authorizations.authorized": "|".join(other_vessel_authorized_rfmos),
        "encounter.encountered_vessel.authorizations.unknown": "|".join(other_vessel_unknown_rfmos),
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
