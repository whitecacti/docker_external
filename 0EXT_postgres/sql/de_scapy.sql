-- docker exec -it postgres_de sh

-- load it in as per 
-- https://github.com/CrunchyData/pg_parquet/
SELECT * FROM parquet.list('/tmp/descapy/**/*.parquet');
SELECT * FROM parquet.schema('/tmp/descapy/year=2025/month=12/day=27/hour=6/part-00007-4a64b7e5-24a3-4b6f-9b2b-33b759fea816.c000.snappy.parquet') LIMIT 10;
SELECT * FROM parquet.read('/tmp/descapy/year=2025/month=12/day=27/hour=6/part-00007-4a64b7e5-24a3-4b6f-9b2b-33b759fea816.c000.snappy.parquet') limit 100;

drop table descapy;
CREATE TABLE descapy (
    ssid BYTEA,
    bssid TEXT,
    channel BIGINT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    signal_strength BIGINT,
    time TEXT,
    source_file TEXT,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    hour INTEGER
);

-- copy the parquet file to the table
COPY descapy FROM '/tmp/descapy/**/*.parquet';

-- see the data 
select 
  *
from (
SELECT 
  convert_from(trim(both E'\\000' from ssid), 'UTF8') as ssid_text,
  bssid,
  channel,
  latitude,
  longitude,
  signal_strength,
  time
FROM descapy)
where true 
and ssid_text != ''
limit 100
;

-- see locations 
select
    *
    , ST_DistanceSphere(
        ST_MakePoint(longitude::float, latitute::float), 
        ST_MakePoint(-100.130, 10.600)       -- Point X: (lon, lat)
    ) as distance_meters
from (
    select
        ssid
        , bssid
        , left(latitude::text,6) as latitute
        , left(longitude::text,8) as longitude
        , RANK() OVER (
            PARTITION BY ssid, bssid
            ORDER BY count(*) desc) AS rank
    from (
        SELECT
          convert_from(trim(both E'\\000' from ssid), 'UTF8') as ssid,
          bssid,
          channel,
          latitude,
          longitude,
          signal_strength,
          time
        FROM descapy)
    where true
    and ssid not in ('','xyz')
    and latitude is not null
    and longitude is not null
    group by 1,2,3,4)
where true
-- and ssid = 'xyz'
and ssid ilike '%fbi%'
and rank = 1