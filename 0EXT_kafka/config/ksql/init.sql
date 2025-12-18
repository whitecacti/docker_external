-- TODO
    -- it should be possible to get offset in a stream

CREATE STREAM new_data_topic_stream (
    `key` VARCHAR,
    `source` VARCHAR,
    `TIMESTAMP` VARCHAR,       
    `reading` INT,
    `kafka_offset` BIGINT
) WITH (
    KAFKA_TOPIC = 'new_data_topic',
    VALUE_FORMAT = 'JSON',
    TIMESTAMP = 'TIMESTAMP',  
    TIMESTAMP_FORMAT = 'yyyy-MM-dd HH:mm:ss.SSSSSS',
    PARTITIONS = 5
);

-- https://docs.confluent.io/platform/current/ksqldb/quickstart.html
CREATE STREAM riderLocations (
    profileId VARCHAR
    , latitude DOUBLE
    , longitude DOUBLE
) WITH (
    kafka_topic='locations'
    , value_format='json'
    , partitions=4);

INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('c2309eec', 37.7877, -122.4205);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('18f4ea86', 37.3903, -122.0643);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4ab5cbad', 37.3952, -122.0813);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('8b6eae59', 37.3944, -122.0813);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4a7c7b41', 37.4049, -122.0822);
INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4ddad000', 37.7857, -122.4011);

-- create material view
-- this view created a persistent query named `CTAS_CURRENTLOCATION_9`
CREATE TABLE currentLocation AS
  SELECT profileId,
         LATEST_BY_OFFSET(latitude) AS la,
         LATEST_BY_OFFSET(longitude) AS lo
  FROM riderLocations
  GROUP BY profileId
  EMIT CHANGES;

-- 
-- Create the ridersNearMountainView table
-- Created query id `CTAS_RIDERSNEARMOUNTAINVIEW_11`
CREATE TABLE ridersNearMountainView AS
  SELECT ROUND(GEO_DISTANCE(la, lo, 37.4133, -122.1162), -1) AS distanceInMiles,
         COLLECT_LIST(profileId) AS riders,
         COUNT(*) AS count
  FROM currentLocation
 GROUP BY ROUND(GEO_DISTANCE(la, lo, 37.4133, -122.1162), -1);
-- running `select * from ridersNearMountainView` will not work on this
    -- `SELECT * from ridersNearMountainView WHERE distanceInMiles <= 10;`
    -- `SELECT * from ridersNearMountainView;`

-- Discord testing
-- {
-- 	"id": 0000000000000,
-- 	"channel_id": 0000000000000,
-- 	"author": "xyz",
-- 	"content": "this is a message",
-- 	"timestamp": "2025-12-18 07:35:19.879000+00:00",
-- 	"attachments": []
-- }
CREATE STREAM discord_stream (
    id BIGINT,
    channel_id BIGINT,
    author VARCHAR,
    content VARCHAR,
    timestamp VARCHAR,
    attachments ARRAY<VARCHAR>
) WITH (
    KAFKA_TOPIC='discord_topic',
    VALUE_FORMAT='JSON',
    PARTITIONS=1
);