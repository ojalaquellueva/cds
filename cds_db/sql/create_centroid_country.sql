-- -----------------------------------------------------------------
-- Create table of countries and their centroids
-- -----------------------------------------------------------------

-- Create table
DROP TABLE IF EXISTS centroid_country;
CREATE TABLE centroid_country (
id bigserial not null primary key,
gid text,
country text,
geom geometry
);

-- Insert country polygons
INSERT INTO centroid_country (
gid,
country,
geom
)
SELECT 
gid_0,
name_0,
ST_Union(geom)
FROM gadm
GROUP BY gid_0, name_0
;

/*
Regular centroid
For calculation of additional centroid types using ST_PointOnSurface
and ST_GeometricMedian, see https://postgis.net/docs/ST_Centroid.html
Also, consider using geography column instead
*/
ALTER TABLE centroid_country
ADD COLUMN centroid geometry(Point,4326)
;

UPDATE centroid_country
SET centroid=ST_Centroid(geom)
;

/*
Point-on-surface centroid
Guaranteed to be inside polygon
But: not sure how handles multipolygons.
See https://postgis.net/docs/ST_Centroid.html
*/
ALTER TABLE centroid_country
ADD COLUMN centroid_pos geometry(Point,4326)
;

UPDATE centroid_country
SET centroid_pos=ST_PointOnSurface(geom)
;

/*
Convenience decimal lat & long columns for each centroid type
*/
ALTER TABLE centroid_country
ADD COLUMN centroid_lat NUMERIC(11, 8),
ADD COLUMN centroid_long NUMERIC(11, 8),
ADD COLUMN centroid_pos_lat NUMERIC(11, 8),
ADD COLUMN centroid_pos_long NUMERIC(11, 8)
;

UPDATE centroid_country
SET
centroid_lat=ST_Y(centroid),
centroid_long=ST_X(centroid),
centroid_pos_lat=ST_Y(centroid_pos),
centroid_pos_long=ST_X(centroid_pos)
;

