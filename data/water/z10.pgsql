SELECT
  osm_id AS gid,
  st_asbinary(way) AS geom,
  (
    CASE
      WHEN waterway = 'dock'
        THEN 'dock'
      WHEN waterway = 'canal'
        THEN 'canal'
      WHEN waterway = 'river'
        THEN 'river'
    END
  ) AS kind,
  coalesce("name:lt", name) AS name,
  case when "waterway:speed" is null then 'N' else 'Y' end as virtual
FROM
  planet_osm_line
WHERE
  way && !BBOX! AND
  waterway IN ('dock', 'canal', 'river')

UNION ALL

SELECT
  row_number() over() AS gid,
  st_asbinary(st_union(way)) AS geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  planet_osm_polygon
WHERE
  way && !BBOX! AND
  waterway = 'riverbank' AND
  way_area >= 204800

UNION ALL

SELECT
  (row_number() over()) + 1000 AS gid,
  st_asbinary(st_union(way)) AS geom,
  'water' AS kind,
  null AS name,
  null AS virtual
FROM
  gen_water
WHERE
  way && !BBOX! AND
  res = 150 AND
  way_area >= 204800
