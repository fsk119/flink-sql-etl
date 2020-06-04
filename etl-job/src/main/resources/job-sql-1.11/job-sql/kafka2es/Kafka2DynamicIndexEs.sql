create table currency(
    currency_id BIGINT,
    currency_name STRING,
    rate DOUBLE,
    currency_timestamp TIMESTAMP(3),
    country STRING,
    precise_timestamp TIMESTAMP(6),
    precise_time TIME(6),
    gdp DECIMAL(10, 6)
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:mysql://localhost:3306/flink',
    'driver' = 'com.mysql.jdbc.Driver',
    'table-name' = 'currency',
    'username' = 'root',
    'password' = '123456',
    'lookup.cache.max-rows' = '5000',
    'lookup.cache.ttl' = '10s',
    'sink.max-retries' = '3'
)

CREATE TABLE es_currency (
    currency_id BIGINT,
    currency_name STRING,
    rate DOUBLE,
    currency_timestamp TIMESTAMP(3),
    country STRING,
    precise_timestamp TIMESTAMP(6),
    precise_time TIME(6),
    gdp DECIMAL(10, 6)
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://localhost:9200',
    'index' = 'dynamic-index-{currency_id}',
    'document-id.key-delimiter' = '$',
    'sink.bulk-flush.interval' = '1000',
    'format' = 'json'
)

INSERT INTO es_currency 
SELECT currency_id, currency_name, rate, currency_timestamp, country, precise_timestamp, precise_time, gdp
FROM currency;


