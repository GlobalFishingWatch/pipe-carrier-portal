WITH
  -------------------------------------------------------------------------------- 
  -- SSVID that are likely fishing gear
  -------------------------------------------------------------------------------- 
  likely_gear AS (
  SELECT
    ssvid
  FROM
    `gfw_research.vi_ssvid_v20200115`
  WHERE
    REGEXP_CONTAINS(ais_identity.shipname_mostcommon.value, r"(.*)([\s]+[0-9]+%)$")
    OR REGEXP_CONTAINS(ais_identity.shipname_mostcommon.value, r"[0-9]\.[0-9]V")
    OR REGEXP_CONTAINS(ais_identity.shipname_mostcommon.value, r"(.*)[@]+([0-9]+V[0-9]?)$")
    OR REGEXP_CONTAINS(ais_identity.shipname_mostcommon.value, r"BOUY")
    OR REGEXP_CONTAINS(ais_identity.shipname_mostcommon.value, r"NET MARK")
    OR REGEXP_CONTAINS(ais_identity.shipname_mostcommon.value, r"NETMARK")
    OR REGEXP_CONTAINS(ais_identity.shipname_mostcommon.value, r"^[0-9]*\-[0-9]*$")),
  -------------------------------------------------------------------------------- 
  -- List of problem MMSI to manually exclude
  -------------------------------------------------------------------------------- 
  bad_mmsi AS (
  SELECT
    CAST(ssvid AS string) AS ssvid
  FROM
    gfw_research.bad_mmsi
  CROSS JOIN
    UNNEST(ssvid) AS ssvid ),
  -------------------------------------------------------------------------------- 
  -- All fishing vesels according to the vi_ssvid tables
  -------------------------------------------------------------------------------- 
  fishing_mmsi AS (
  SELECT
    vi_by_year.ssvid,
    vi_by_year.activity.first_timestamp AS first_timestamp,
    vi_by_year.activity.last_timestamp AS last_timestamp,
  FROM
    -- This is a bit of a hack due to some limitations on how the vessel class
    -- system works right now on the vessel info tables. Unfortunately, the
    -- yearly table doesn't have vessel inference data for 2019 and 2020. We
    -- will fall back to using the global values instead for inference by
    -- joining with the global table here and using the values in the global
    -- table for inference fields. Hopefully, once we have rolling window
    -- monthly runs of vessel inference we can include updated inference
    -- information on each yearly record, and so this won't be required.
    `gfw_research.vi_ssvid_byyear_v20200115` AS vi_by_year
  INNER JOIN
    `gfw_research.vi_ssvid_v20200115` AS vi_global
  USING
    (ssvid)
  WHERE
    -- MMSI best fishing list
    vi_by_year.on_fishing_list_best
    -- MMSI used by 2+ vessels simultaneously for fewer than 24 hours
    AND (vi_by_year.activity.overlap_hours_multinames < 24
      OR vi_by_year.activity.overlap_hours_multinames IS NULL)
    -- MMSI not offsetting position
    AND vi_by_year.activity.offsetting IS FALSE
    -- MMSI associated with 5 or fewer different shipnames
    AND 5 >= (
    SELECT
      COUNT(*)
    FROM (
      SELECT
        value,
        SUM(count) AS count
      FROM
        UNNEST(vi_by_year.ais_identity.n_shipname)
      WHERE
        value IS NOT NULL
      GROUP BY
        value)
    WHERE
      count >= 10)
    -- MMSI not likely gear
    AND vi_by_year.ssvid NOT IN (
    SELECT
      ssvid
    FROM
      likely_gear )
    -- MMSI non in bad MMSI's
    AND vi_by_year.ssvid NOT IN (
    SELECT
      ssvid
    FROM
      bad_mmsi)
    -- MMSI vessel class can be inferred by the neural net
    AND vi_global.inferred.inferred_vessel_class IS NOT NULL -- active
    -- MMSI fished for at least 24 hours in the year. Noise filter.
    AND vi_by_year.activity.fishing_hours > 24
    -- MMSI was active at least during 5 full days. Noise filter.
    AND vi_by_year.activity.active_hours > 24*5 ),
  -------------------------------------------------------------------------------- 
  -- Extract the final yearly information
  -------------------------------------------------------------------------------- 
  results AS (
  SELECT
    ssvid,
    EXTRACT(year
    FROM
      first_timestamp) AS year,
  FROM
    fishing_mmsi)
SELECT
  *
FROM
  results
