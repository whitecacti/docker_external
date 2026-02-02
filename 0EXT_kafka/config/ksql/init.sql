-- TODO
    -- it should be possible to get offset in a stream

-- DROP STREAM IF EXISTS new_data_topic_stream;
-- CREATE STREAM new_data_topic_stream (
--     `key` VARCHAR,
--     `source` VARCHAR,
--     `TIMESTAMP` VARCHAR,       
--     `reading` INT,
--     `kafka_offset` BIGINT
-- ) WITH (
--     KAFKA_TOPIC = 'new_data_topic',
--     VALUE_FORMAT = 'JSON',
--     TIMESTAMP = 'TIMESTAMP',  
--     TIMESTAMP_FORMAT = 'yyyy-MM-dd HH:mm:ss.SSSSSS',
--     PARTITIONS = 5
-- );

-- https://docs.confluent.io/platform/current/ksqldb/quickstart.html
-- DROP STREAM IF EXISTS riderLocations;
-- CREATE STREAM riderLocations (
--     profileId VARCHAR
--     , latitude DOUBLE
--     , longitude DOUBLE
-- ) WITH (
--     kafka_topic='locations'
--     , value_format='json'
--     , partitions=4);

-- INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('c2309eec', 37.7877, -122.4205);
-- INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('18f4ea86', 37.3903, -122.0643);
-- INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4ab5cbad', 37.3952, -122.0813);
-- INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('8b6eae59', 37.3944, -122.0813);
-- INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4a7c7b41', 37.4049, -122.0822);
-- INSERT INTO riderLocations (profileId, latitude, longitude) VALUES ('4ddad000', 37.7857, -122.4011);

-- create material view
-- this view created a persistent query named `CTAS_CURRENTLOCATION_9`
-- DROP TABLE IF EXISTS currentLocation;
-- CREATE TABLE currentLocation AS
--   SELECT profileId,
--          LATEST_BY_OFFSET(latitude) AS la,
--          LATEST_BY_OFFSET(longitude) AS lo
--   FROM riderLocations
--   GROUP BY profileId
--   EMIT CHANGES;

-- 
-- Create the ridersNearMountainView table
-- Created query id `CTAS_RIDERSNEARMOUNTAINVIEW_11`
-- DROP TABLE IF EXISTS ridersNearMountainView;
-- CREATE TABLE ridersNearMountainView AS
--   SELECT ROUND(GEO_DISTANCE(la, lo, 37.4133, -122.1162), -1) AS distanceInMiles,
--          COLLECT_LIST(profileId) AS riders,
--          COUNT(*) AS count
--   FROM currentLocation
--  GROUP BY ROUND(GEO_DISTANCE(la, lo, 37.4133, -122.1162), -1);
-- running `select * from ridersNearMountainView` will not work on this
    -- `SELECT * from ridersNearMountainView WHERE distanceInMiles <= 6;`
    -- `SELECT * from ridersNearMountainView;`

-- Discord testing, this will also create a topic
-- {
-- 	"id": 0000000000000,
-- 	"channel_id": 0000000000000,
-- 	"author": "xyz",
-- 	"content": "this is a message",
-- 	"timestamp": "2025-12-18 07:35:19.879000+00:00",
-- 	"attachments": []
-- }
-- DROP STREAM IF EXISTS discord_stream;
-- CREATE STREAM discord_stream (
--     id BIGINT,
--     channel_id BIGINT,
--     author VARCHAR,
--     content VARCHAR,
--     timestamp VARCHAR,
--     attachments ARRAY<VARCHAR>
-- ) WITH (
--     KAFKA_TOPIC='discord_topic',
--     VALUE_FORMAT='JSON',
--     PARTITIONS=1
-- );


-- wikipedia streams
-- this is the real name of the topic - codfw.mediawiki.recentchange
-- DROP STREAM IF EXISTS wikimedia_recent_changes;
-- SET 'auto.offset.reset' = 'earliest'; 
-- CREATE STREAM wikimedia_recent_changes (
--     `$schema` VARCHAR,
--     meta STRUCT<
--         uri VARCHAR,
--         request_id VARCHAR,
--         id VARCHAR,
--         domain VARCHAR,
--         `stream` VARCHAR, 
--         dt VARCHAR,
--         `topic` VARCHAR,
--         `partition` INT,
--         `offset` BIGINT
--     >,
--     id BIGINT,
--     `type` VARCHAR,
--     `namespace` INT,
--     title VARCHAR,
--     title_url VARCHAR,
--     comment VARCHAR,
--     `timestamp` BIGINT,
--     `user` VARCHAR,
--     bot BOOLEAN,
--     notify_url VARCHAR,
--     server_url VARCHAR,
--     server_name VARCHAR,
--     server_script_path VARCHAR,
--     wiki VARCHAR,
--     parsedcomment VARCHAR
-- ) WITH (
--     KAFKA_TOPIC = 'wikipedia_all', 
--     VALUE_FORMAT = 'JSON'
-- );

-- flattening the above
-- DROP STREAM IF EXISTS wikimedia_recent_changes_flat;
-- CREATE STREAM wikimedia_recent_changes_flat AS
-- SELECT
--     `$schema`,
--     -- Flattening the 'meta' struct
--     meta->uri AS meta_uri,
--     meta->request_id AS meta_request_id,
--     meta->id AS meta_id,
--     meta->domain AS meta_domain,
--     meta->`stream` AS meta_stream,
--     meta->dt AS meta_dt,
--     meta->`topic` AS meta_topic,
--     meta->`partition` AS meta_partition,
--     meta->`offset` AS meta_offset,
--     -- Selecting root level fields
--     id,
--     `type`,
--     `namespace`,
--     title,
--     title_url,
--     comment,
--     `timestamp`,
--     `user`,
--     bot,
--     notify_url,
--     server_url,
--     server_name,
--     server_script_path,
--     wiki,
--     parsedcomment
-- FROM wikimedia_recent_changes
-- EMIT CHANGES;

-- CREATE TABLE AS SELECT (CTAS) - Or Materialized View
-- make sure the table has everything from the begginning
-- DROP TABLE IF EXISTS wikipedia_distinct_domains;
-- SET 'auto.offset.reset' = 'earliest'; 
-- CREATE TABLE wikipedia_distinct_domains AS
-- SELECT
--     meta_domain,
--     COUNT(*) AS total_occurrences,
--     LATEST_BY_OFFSET(`timestamp`) AS last_seen
-- FROM wikimedia_recent_changes_flat
-- GROUP BY meta_domain
-- EMIT CHANGES;

-- CREATE STREAM AS SELECT (CSAS)
-- DROP STREAM IF EXISTS wikipedia_us_changes;
-- CREATE STREAM wikipedia_us_changes AS
-- SELECT *
-- FROM wikimedia_recent_changes_flat
-- WHERE meta_domain = 'en.wikipedia.org'
-- EMIT CHANGES;

-- all the kalshi stuff
-- DEMO TICKER
DROP STREAM IF EXISTS KALSHI_TICKER_FLATTENED_AVRO_DEMO;
DROP STREAM IF EXISTS kalshi_ticker_raw_demo;
CREATE STREAM kalshi_ticker_raw_demo (
    type VARCHAR,
    sid BIGINT,
    msg STRUCT<
        market_id VARCHAR, market_ticker VARCHAR, price INT, yes_bid INT, yes_ask INT,
        price_dollars VARCHAR, yes_bid_dollars VARCHAR, yes_ask_dollars VARCHAR,
        volume BIGINT, volume_fp VARCHAR, open_interest BIGINT, open_interest_fp VARCHAR,
        dollar_volume BIGINT, dollar_open_interest BIGINT, ts BIGINT, Clock BIGINT
    >
) WITH (KAFKA_TOPIC='kalshi_ticker_demo', VALUE_FORMAT='JSON', PARTITIONS=6, REPLICAS=1);

SET 'auto.offset.reset' = 'earliest';
CREATE STREAM KALSHI_TICKER_FLATTENED_AVRO_DEMO WITH (VALUE_FORMAT='AVRO') AS
SELECT 
    type, sid, msg->market_id, msg->market_ticker, msg->price, msg->yes_bid, msg->yes_ask,
    msg->price_dollars, msg->yes_bid_dollars, msg->yes_ask_dollars, msg->volume,
    msg->volume_fp, msg->open_interest, msg->open_interest_fp, msg->dollar_volume,
    msg->dollar_open_interest, msg->ts AS ts_unix, msg->Clock AS clock
FROM kalshi_ticker_raw_demo EMIT CHANGES;

-- REAL MONEY TICKER
DROP STREAM IF EXISTS KALSHI_TICKER_FLATTENED_AVRO_REAL_MONEY;
DROP STREAM IF EXISTS kalshi_ticker_raw_real_money;
CREATE STREAM kalshi_ticker_raw_real_money (
    type VARCHAR,
    sid BIGINT,
    msg STRUCT<
        market_id VARCHAR, market_ticker VARCHAR, price INT, yes_bid INT, yes_ask INT,
        price_dollars VARCHAR, yes_bid_dollars VARCHAR, yes_ask_dollars VARCHAR,
        volume BIGINT, volume_fp VARCHAR, open_interest BIGINT, open_interest_fp VARCHAR,
        dollar_volume BIGINT, dollar_open_interest BIGINT, ts BIGINT, Clock BIGINT
    >
) WITH (KAFKA_TOPIC='kalshi_ticker_real_money', VALUE_FORMAT='JSON', PARTITIONS=6, REPLICAS=1);

CREATE STREAM KALSHI_TICKER_FLATTENED_AVRO_REAL_MONEY WITH (VALUE_FORMAT='AVRO') AS
SELECT 
    type, sid, msg->market_id, msg->market_ticker, msg->price, msg->yes_bid, msg->yes_ask,
    msg->price_dollars, msg->yes_bid_dollars, msg->yes_ask_dollars, msg->volume,
    msg->volume_fp, msg->open_interest, msg->open_interest_fp, msg->dollar_volume,
    msg->dollar_open_interest, msg->ts AS ts_unix, msg->Clock AS clock
FROM kalshi_ticker_raw_real_money EMIT CHANGES;

-- DEMO TRADE
DROP STREAM IF EXISTS KALSHI_TRADE_FLATTENED_AVRO_DEMO;
DROP STREAM IF EXISTS kalshi_trade_raw_demo;
CREATE STREAM kalshi_trade_raw_demo (
    type VARCHAR, sid BIGINT, seq BIGINT,
    msg STRUCT<
        trade_id VARCHAR, market_ticker VARCHAR, yes_price INT, no_price INT,
        yes_price_dollars VARCHAR, no_price_dollars VARCHAR, count INT,
        count_fp VARCHAR, taker_side VARCHAR, ts BIGINT
    >
) WITH (KAFKA_TOPIC='kalshi_trade_demo', VALUE_FORMAT='JSON', PARTITIONS=6, REPLICAS=1);

CREATE STREAM KALSHI_TRADE_FLATTENED_AVRO_DEMO WITH (VALUE_FORMAT='AVRO') AS
SELECT 
    type, sid, seq, msg->trade_id, msg->market_ticker, msg->yes_price, msg->no_price,
    msg->yes_price_dollars, msg->no_price_dollars, msg->count, msg->count_fp,
    msg->taker_side, msg->ts AS ts_unix, FROM_UNIXTIME(msg->ts * 600) AS ts_readable
FROM kalshi_trade_raw_demo EMIT CHANGES;

-- REAL MONEY TRADE
DROP STREAM IF EXISTS KALSHI_TRADE_FLATTENED_AVRO_REAL_MONEY;
DROP STREAM IF EXISTS kalshi_trade_raw_real_money;
CREATE STREAM kalshi_trade_raw_real_money (
    type VARCHAR, sid BIGINT, seq BIGINT,
    msg STRUCT<
        trade_id VARCHAR, market_ticker VARCHAR, yes_price INT, no_price INT,
        yes_price_dollars VARCHAR, no_price_dollars VARCHAR, count INT,
        count_fp VARCHAR, taker_side VARCHAR, ts BIGINT
    >
) WITH (KAFKA_TOPIC='kalshi_trade_real_money', VALUE_FORMAT='JSON', PARTITIONS=6, REPLICAS=1);

CREATE STREAM KALSHI_TRADE_FLATTENED_AVRO_REAL_MONEY WITH (VALUE_FORMAT='AVRO') AS
SELECT 
    type, sid, seq, msg->trade_id, msg->market_ticker, msg->yes_price, msg->no_price,
    msg->yes_price_dollars, msg->no_price_dollars, msg->count, msg->count_fp,
    msg->taker_side, msg->ts AS ts_unix, FROM_UNIXTIME(msg->ts * 600) AS ts_readable
FROM kalshi_trade_raw_real_money EMIT CHANGES;

-- DEMO LIFECYCLE
DROP STREAM IF EXISTS KALSHI_MARKET_LIFECYCLE_FLATTENED_AVRO_DEMO;
DROP STREAM IF EXISTS kalshi_market_lifecycle_raw_demo;
CREATE STREAM kalshi_market_lifecycle_raw_demo (
    type VARCHAR, sid BIGINT, seq BIGINT,
    msg STRUCT<market_ticker VARCHAR, determination_ts BIGINT, result VARCHAR, event_type VARCHAR>
) WITH (KAFKA_TOPIC='kalshi_market_lifecycle_demo', VALUE_FORMAT='JSON', PARTITIONS=1, REPLICAS=1);

CREATE STREAM KALSHI_MARKET_LIFECYCLE_FLATTENED_AVRO_DEMO WITH (VALUE_FORMAT='AVRO') AS
SELECT 
    type, sid, seq, msg->market_ticker, msg->determination_ts, msg->result, msg->event_type,
    FROM_UNIXTIME(msg->determination_ts * 600) AS determination_ts_readable
FROM kalshi_market_lifecycle_raw_demo EMIT CHANGES;

-- REAL MONEY LIFECYCLE
DROP STREAM IF EXISTS KALSHI_MARKET_LIFECYCLE_FLATTENED_AVRO_REAL_MONEY;
DROP STREAM IF EXISTS kalshi_market_lifecycle_raw_real_money;
CREATE STREAM kalshi_market_lifecycle_raw_real_money (
    type VARCHAR, sid BIGINT, seq BIGINT,
    msg STRUCT<market_ticker VARCHAR, determination_ts BIGINT, result VARCHAR, event_type VARCHAR>
) WITH (KAFKA_TOPIC='kalshi_market_lifecycle_real_money', VALUE_FORMAT='JSON', PARTITIONS=1, REPLICAS=1);

CREATE STREAM KALSHI_MARKET_LIFECYCLE_FLATTENED_AVRO_REAL_MONEY WITH (VALUE_FORMAT='AVRO') AS
SELECT 
    type, sid, seq, msg->market_ticker, msg->determination_ts, msg->result, msg->event_type,
    FROM_UNIXTIME(msg->determination_ts * 600) AS determination_ts_readable
FROM kalshi_market_lifecycle_raw_real_money EMIT CHANGES;