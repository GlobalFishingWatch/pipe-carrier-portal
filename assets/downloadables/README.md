# Carrier portal events, version {{ dataset_version }}

## Description

Data from the [Carrier Vessel Portal](https://globalfishingwatch.org/carrier-portal/) public portal to help policymakers and fishery managers better understand the activity of carriers, refrigerated cargo vessels that can support the transfer of fish from commercial fishing vessels out at sea and delivery of fish to ports for processing worldwide.

The Carrier Vessel Portal utilizes AIS data to show the historical activity of carriers, including port visits, loitering and encounter events, as well as tuna RFMOs authorization for both carriers and fishing vessels to enable the user a full picture of carrier patterns. 

Check out our [FAQ](https://globalfishingwatch.org/article-categories/carrier-vessel-portal/), [Data & Terminology disclaimers](https://globalfishingwatch.org/carrier-vessel-portal-disclaimers/) and [Authorization records](https://globalfishingwatch.org/authorization-records/) for further information.

## Contents

This dataset contains the vessel encounter, loitering and port events as available on the Carrier Vessel Portal

We include 3 event types in this dataset, each on it's own zipped CSV file:

* `encounter`: Encounters between a carrier and a fishing vessel. More information [here](https://globalfishingwatch.org/faqs/what-is-an-encounter-in-the-carrier-vessel-portal/).

* `loitering`: Carrier vessels exhibiting behavior indicative of a potential encounter event. More information [here](https://globalfishingwatch.org/faqs/what-are-loitering-events-in-the-carrier-vessel-portal/).

* `port`: Vessels potentially docking or waiting in an anchorage. More information [here](https://globalfishingwatch.org/faqs/how-are-port-visits-in-the-carrier-vessel-portal-defined/).

## Files

These are the files available in this dataset:

* `encounters.zip`: Zipped CSV file containing all the encounter events.

* `loitering.zip`: Zipped CSV file containing all the loitering events.

* `port.zip`: Zipped CSV file containing all the port events.

All event files share the same schema with the same columns.

### File schema

The columns in all 3 event files is the same, to make it easier to merge the files together if necessary. Some of the columns are always empty in some of the files when the field is not applicable to the event type of that file, i.e.: loitering events do not have an encountered vessel so all the columns related to the encountered vessel are empty in the loitering CSV file.

These are the columns that are included in the CSV files: 

* `id`: Internal unique identifier for the event

* `type`: Type of event, one of `loitering`, `encounter` or `port`. Each file contains records with only one type (the `loitering.zip` file only contains records with type `loitering`).

* `start`: UTC timestamp when the event started.

* `end`: UTC timestamp when the event ended.

* `lat`: Latitude of the mean position for the event in decimal degrees.

* `lon`: Longitude of the mean position for the event in decimal degrees.

* `vessel.id`: Internal unique identifier for the main vessel involved in the event. In the case of encounters this is the carrier vessel.

* `vessel.type`: Type of vessel the main vessel is. One of `carrier` or `fishing`. In the case of encounter and loitering events, this will always be `carrier`. In the case of port events, it can be either.

* `vessel.mmsi`: MMSI for the main vessel in the event.

* `vessel.name`: Ship name for the main vessel in the event.

* `vessel.flag`: Inferred flag for the main vessel, as determined from the MMSI midcode.

* `vessel.origin_port.country`: Country ISO3 code for the port visited by the main vessel at the start of the trip prior to the event. Only available in encounter and loitering events.

* `vessel.origin_port.name`: Port name for the port visited by the main vessel at the start of the trip prior to the event. Only available in encounter and loitering events.

* `vessel.destination_port.country`: Country ISO3 code for the port visited by the main vessel at the end of the trip after the event. Only available in encounter and loitering events.

* `vessel.destination_port.name`: Port name for the port visited by the main vessel at the end of the trip after the event. Only available in encounter and loitering events.

* `vessel.authorizations.authorized`: List of RFMO's separated by a `|` character (i.e: `NPFC|SPRFMO`) where the event happened for which we've found matching authorization records for the main vessel. Only available in encounter events.

* `vessel.authorizations.unknown`: List of RFMO's separated by a `|` character (i.e: `NPFC|SPRFMO`) where the event happened for which we haven't found matching authorization records for the main vessel. Only available in encounter events

* `median_speed_knots`: Median speed in knots for the vessel while the event was happening. Only available in loitering and encounter events.

* `elevation_m`: Bathymetry information at the mean position of the event, in meters.

* `distance_from_shore_m`: Distance from the closest shore at the mean position of the event, in meters.

* `distance_from_port_m`: Distance from the closest port at the mean position of the event, in meters.

* `regions.rfmo`: List of RFMOs separated by a `|` character where the event happened. This is the complete list of RFMO's where the event happened, including RFMO's that we don't pull authorization information from.

* `encounter.median_distance_km`: Median distance between the vessels while the encouter is happening. This is only available on encounter events.

* `encounter.authorization_status`: General authorization status for the encounter, based on the authorization status of the carrier vessel participating in the event. Either `unknown` if we don't have authorization information for all the possibly overlapping RFMOs, `partial` if some (but not all) are authorized or `authorized` if we do know the vessel is authorized in all possible overlapping RFMOs. Only available for encounter events.

* `encounter.encountered_vessel.id`: Internal unique identifier for the encountered fishing vessel involved in the event. Only available for encounter events.

* `encounter.encountered_vessel.type`: Type of the encountered vessel. Always `fishing`. Only available for encounter events.

* `encounter.encountered_vessel.mmsi`: MMSI for the encountered fishing vessel.  Only available for encounter events.

* `encounter.encountered_vessel.name`: Ship name for the encountered fishing vessel. Only available for encounter events.

* `encounter.encountered_vessel.flag`: Inferred flag for the encountered fishing vessel, as determined from the MMSI midcode. Only available for encounter events.

* `encounter.encountered_vessel.origin_port.country`: Country ISO3 code for the port visited by the encountered fishing vessel at the start of the trip prior to the event.  Only available in encounter events.

* `encounter.encountered_vessel.origin_port.name`: Port name for the port visited by the encountered fishing vessel at the start of the trip prior to the event. Only available in encounter events.

* `encounter.encountered_vessel.destination_port.country`: Country ISO3 code for the port visited by the encountered fishing vessel at the end of the trip after the event. Only available in encounter events.

* `encounter.encountered_vessel.destination_port.name`: Port name for the port visited by the encountered fishing vessel at the end of the trip after the event. Only available in encounter events.

* `encounter.encountered_vessel.authorizations.authorized`: List of RFMO's separated by a `|` character (i.e: `NPFC|SPRFMO`) where the event happened for which we've found matching authorization records for the encountered fishing vessel. Only available in encounter events.

* `encounter.encountered_vessel.authorizations.unknown`: List of RFMO's separated by a `|` character (i.e: `NPFC|SPRFMO`) where the event happened for which we haven't found matching authorization records for the encountered fishing vessel. Only available in encounter events.

* `loitering.total_distance_km`: Total distance traveled by the carrier vessel while the event was happening. Only available in loitering events

* `loitering.loitering_hours`: Total amount of time the carrier vessel was loitering. Only available in loitering events.

* `port.lat`: Inferred latitude of the position for the anchorage inside the port where the vessel docked in decimal degrees. Only available in port events.

* `port.lon`: Inferred longitude of the position for the anchorage inside the port where the vessel docked in decimal degrees. Only available in port events.

* `port.country`: ISO3 code for the country owning the port where the vessel docked. Only available in port events.

* `port.name`: Name for the port where the vessel docked. Only available in port events.

