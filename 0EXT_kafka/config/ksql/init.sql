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
    PARTITIONS = 1
);

-- it should be possible to get offset in a stream