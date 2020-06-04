## batch
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
    'index' = 'cli_test',
--  'document-type' = '_doc',
--  'failure-handler' = 'fail'
    'document-id.key-delimiter' = '$',
    'sink.bulk-flush.interval' = '1000',
    'format' = 'json'
)
INSERT INTO es_currency 
SELECT currency_id, currency_name, rate, currency_timestamp, country, precise_timestamp, precise_time, gdp 
FROM currency

 ## streaming
CREATE TABLE orders (
  order_id STRING,
  item    STRING,
  currency STRING,
  amount DOUBLE,
  order_time TIMESTAMP(3),
  proc_time as PROCTIME(),
  amount_kg as amount * 1000,
  ts as order_time + INTERVAL '1' SECOND,
  WATERMARK FOR order_time AS order_time
) WITH (
  'connector' = 'kafka',
  'topic' = 'orders',
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'json'
)

CREATE TABLE es_orders(
    order_id STRING,
    item STRING, 
    order_time TIMESTAMP(3)
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://localhost:9200',
    'index' = 'es_orders',
    'document-id.key-delimiter' = '$',
    'sink.bulk-flush.interval' = '1000',
    'format' = 'json'
)


insert into es_orders
select order_id, item, order_time from orders;

