#standardSQL

-- Convert a lat,lon pont in a GEOGRAPHY, such as created with ST_GEOGPOINT(lon, lat)
-- Retrns a STRUCT(lon, lat)
--
-- It seems ridiculous that we have to convert to json and then parse it to do this, but bigquery
-- does not provide any other way to get the lat/lon out of a GEOGRAPHY
CREATE TEMPORARY FUNCTION
  geopoint_to_struct (pt GEOGRAPHY) AS ( STRUCT( CAST(JSON_EXTRACT_SCALAR(ST_ASGEOJSON(pt),
          "$['coordinates'][0]") AS FLOAT64) AS lon,
      CAST(JSON_EXTRACT_SCALAR(ST_ASGEOJSON(pt),
          "$['coordinates'][1]") AS FLOAT64) AS lat ) );
          
-- Creates a port-id based in the iso3 and the label of the port
CREATE TEMPORARY FUNCTION
  generate_port_id (iso3 STRING,
    label STRING) AS ( LOWER(CONCAT(iso3,"-",REGEXP_REPLACE(NORMALIZE(label),' ',''))) );
    
WITH
  -- SOURCES
  carrier_portal_published_events_loitering AS (
  SELECT
    *
  FROM
    `proj_carrier_portal_pew.carrier_portal_published_events_loitering_v20200720`),
  named_anchorages AS (
  SELECT
    *
  FROM
    `gfw_research.named_anchorages`),
  encounter_ports_ids AS (
  -- GET PORT_IDS from the carriers, since we don't know if they appear in first
  -- or second positions we query both from the json included in the encounter
  -- and only pick carriers.
  SELECT
    port_id
  FROM (
    SELECT
      JSON_EXTRACT_SCALAR(event_info,
          "$.destination_port.port_id") port_id
    FROM
      carrier_portal_published_events_loitering
    WHERE
      EXTRACT(year
      FROM
        event_start) > 2017 )
  GROUP BY
    1 ),
  -- Generate port ids from named anchorages, the same method `generate_port_id` is used
  -- when generating the encoutners
  grouped_named_anchorages_with_port_id AS (
  SELECT
    ST_CENTROID(ST_UNION_AGG(ST_GEOGPOINT(lon,
          lat))) centroid,
    generate_port_id(iso3,
      label) port_id,
    label,
    iso3
  FROM
    named_anchorages
  GROUP BY
    2,
    3,
    4),
  -- Filter ports, only include:
  -- Ports where carriers go after a transhipment
  -- Are not chineses, we remove chinese since there is lots of noise
  -- If we get a good dataset from CHina we can remove this filter.
  encounter_ports AS(
  SELECT
    port_id,
    label,
    iso3,
    ROUND(geopoint_to_struct(centroid).lat,5) lat,
    ROUND(geopoint_to_struct(centroid).lon,5) lon
  FROM
    grouped_named_anchorages_with_port_id
  WHERE
    port_id IN (
    SELECT
      port_id
    FROM
      encounter_ports_ids)
    AND iso3 != "CHN"
  GROUP BY
    1,
    2,
    3,
    4,
    5 ),
  -- Add the RFMO to the ports
  encounter_ports_with_rfmo AS (
  SELECT
    * EXCEPT(gridcode)
  FROM (
    SELECT
      *,
      FORMAT("lon:%+07.2f_lat:%+07.2f", ROUND(lon/0.01)*0.01, ROUND(lat/0.01)*0.01) AS gridcode
    FROM
      encounter_ports
    WHERE
      lat IS NOT NULL
      AND lon IS NOT NULL )
  LEFT JOIN (
    SELECT
      gridcode,
      ARRAY_AGG(rfmo) rfmo_list
    FROM
      `pipe_static.regions`,
      UNNEST(regions.rfmo) rfmo
    WHERE
      rfmo IN ("WCPFC",
        "CCSBT",
        "IATTC",
        "ICCAT",
        "IOTC")
    GROUP BY
      1 )
  USING
    (gridcode))
SELECT
  port_id id,
  label,
  iso3 iso,
  lat,
  lon,
  rfmo_list rfmo
FROM
  encounter_ports_with_rfmo
