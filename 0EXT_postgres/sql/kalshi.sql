-- data comes from 
-- https://github.com/jon-becker/prediction-market-analysis

SELECT * FROM parquet.list('/datasets/kalshi_data/trades/*.parquet');
SELECT * FROM parquet.schema('/datasets/kalshi_data/trades/trades_25770000_25780000.parquet');

DROP TABLE IF exists kalshi_trades;
CREATE TABLE kalshi_trades (
    trade_id      TEXT PRIMARY KEY,
    ticker        TEXT NOT NULL,
    count         BIGINT,
    yes_price     BIGINT,
    no_price      BIGINT,
    taker_side    TEXT,
    created_time  TIMESTAMPTZ,
    _fetched_at   TIMESTAMPTZ
);

-- Optional: Create an index on ticker and time for faster queries
CREATE INDEX idx_trades_ticker_time ON kalshi_trades (ticker, created_time DESC);

ALTER TABLE kalshi_trades SET UNLOGGED;
-- COPY kalshi_trades FROM '/datasets/kalshi_data/trades/*.parquet'; -- old and super slow!!!!
ALTER TABLE kalshi_trades SET LOGGED;

-- using pg_duckdb, super quick!, took about 6m vs >1h
drop table if exists kalshi_trades;
CREATE TABLE kalshi_trades AS
select * from read_parquet('/datasets/kalshi_data/trades/*.parquet');

-----
SELECT * FROM parquet.list('/datasets/kalshi_data/markets/*.parquet');
SELECT * FROM parquet.schema('/datasets/kalshi_data/markets/markets_0_10000.parquet');

DROP TABLE IF EXISTS kalshi_markets;
CREATE TABLE kalshi_markets (
    -- Primary identifier for the market
    ticker TEXT PRIMARY KEY,

    -- Categorization and Metadata
    event_ticker TEXT,
    market_type TEXT,
    title TEXT,
    yes_sub_title TEXT,
    no_sub_title TEXT,
    status TEXT,
    result TEXT,

    -- Market Data (Prices and Volume)
    -- Using BIGINT as these are INT64 in Parquet
    -- THIS IS SUPPOSED TO BE BIG INT, BUT KEPT FAILING. SO THIS IS EZ
    yes_bid TEXT,
    yes_ask TEXT,
    no_bid TEXT,
    no_ask TEXT,
    last_price TEXT,
    volume TEXT,
    volume_24h TEXT,
    open_interest TEXT,

    -- Temporal Data
    -- Using TIMESTAMPTZ to ensure timezone awareness
    created_time TIMESTAMPTZ,
    open_time TIMESTAMPTZ,
    close_time TIMESTAMPTZ,
    _fetched_at TIMESTAMPTZ
);

-- Recommended index for performance if you query by event frequently
CREATE INDEX idx_kalshi_markets_event ON kalshi_markets (event_ticker);

-- COPY kalshi_markets FROM '/datasets/kalshi_data/markets/*.parquet'; -- old and super slow!

-- loading with duckdb
drop table if exists kalshi_markets;
CREATE TABLE kalshi_markets AS
select * from read_parquet('/datasets/kalshi_data/markets/*.parquet');

-- this is size of the data 
SELECT sum(size)
FROM parquet.list('/datasets/kalshi_data/markets/*.parquet');

-- the size of the data when loaded
SELECT pg_size_pretty(pg_relation_size('kalshi_markets'));


------ speed comparisons

-- postgres engine, ~30 seconds
select
    event_ticker
    , count(*)
from kalshi_markets
where true
and event_ticker ilike '%KXSB%'
group by 1
-- order by created_time asc
limit 10

-- pg_duckdb engine, <1 seconds, 30X faster!
select
    r['event_ticker'] as event_ticker
    , count(*)
from read_parquet('/datasets/kalshi_data/markets/*.parquet') as r
where true
and r['event_ticker'] ilike '%KXSB%'
group by 1;



