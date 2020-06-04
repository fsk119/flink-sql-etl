CREATE TABLE orders (
  order_id STRING,
  item    STRING,
  currency STRING,
  amount INT,
  order_time TIMESTAMP(3),
  proc_time as PROCTIME(),
  amount_kg as amount * 1000,
  ts as order_time + INTERVAL '1' SECOND,
  WATERMARK FOR order_time AS order_time
) WITH (
  'connector.type' = 'kafka',
  'connector.version' = 'universal',
  'connector.topic' = 'orders',
  'connector.properties.zookeeper.connect' = 'localhost:2181',
  'connector.properties.bootstrap.servers' = 'localhost:9092',
  'connector.properties.group.id' = 'testGroup3',
  'connector.startup-mode' = 'earliest-offset',
  'format.type' = 'json',
  'format.derive-schema' = 'true'
)

CREATE TABLE currency (
  currency_id BIGINT,
  currency_name STRING,
  rate DOUBLE,
  currency_timestamp  TIMESTAMP,
  country STRING,
  precise_timestamp TIMESTAMP(6),
  precise_time TIME(6),
  gdp DECIMAL(38, 18)
) WITH (
   'connector.type' = 'jdbc',
   'connector.url' = 'jdbc:mysql://localhost:3306/flink',
   'connector.username' = 'root',
   'connector.password' = '123456',
   'connector.table' = 'currency',
   'connector.driver' = 'com.mysql.jdbc.Driver',
   'connector.lookup.cache.max-rows' = '500',
   'connector.lookup.cache.ttl' = '10s',
   'connector.lookup.max-retries' = '3')

CREATE TABLE test_precision3 (
    currency_id BIGINT,
    currency_name STRING, 
    cast_precise_timestamp TIMESTAMP(3)
)WITH(
    'connector.type' = 'jdbc',
    'connector.url' = 'jdbc:mysql://localhost:3306/flink',
    'connector.username' = 'root',
    'connector.password' = '123456',
    'connector.table' = 'test_precision3',
    'connector.driver' = 'com.mysql.jdbc.Driver',
    'connector.lookup.cache.max-rows' = '500',
    'connector.lookup.cache.ttl' = '10s',
    'connector.lookup.max-retries' = '3')

CREATE TABLE test_precision6 (
    currency_id BIGINT,
    currency_name STRING, 
    cast_precise_timestamp TIMESTAMP(6)
)WITH(
    'connector.type' = 'jdbc',
    'connector.url' = 'jdbc:mysql://localhost:3306/flink',
    'connector.username' = 'root',
    'connector.password' = '123456',
    'connector.table' = 'test_precision3',
    'connector.driver' = 'com.mysql.jdbc.Driver',
    'connector.lookup.cache.max-rows' = '500',
    'connector.lookup.cache.ttl' = '10s',
    'connector.lookup.max-retries' = '3')

INSERT INTO test_precision3
SELECT currency_id, currency_name, precise_timestamp
FROM currency;


INSERT INTO test_precision6
SELECT currency_id, currency_name, precise_timestamp
FROM currency;
