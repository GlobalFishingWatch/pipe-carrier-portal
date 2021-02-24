# -*- coding: utf-8 -*-
import sys
import json
import csv
import re

csv_file = sys.argv[1]

with open(csv_file, "w", newline='', encoding='utf-8') as f:
    writer = csv.writer(f)

    for line in sys.stdin:
        record = json.loads(line)

        # Normalize mean_lat and mean_lon into an actual point
        normalized_mean_position = "POINT({} {})".format(
            record['lon_mean'], record['lat_mean'])

        try:
            writer.writerow([
                record['event_id'],
                record['event_type'],
                record['vessel_id'],
                record['event_start'],
                record.get('event_end'),
                record['event_info'],
                record['event_vessels'],
                normalized_mean_position
            ])
        except:
            print(f"Unable to convert record to csv at {record}")
            raise
