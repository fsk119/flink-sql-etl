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
  'connector' = 'kafka',
  'topic' = 'orders',
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'json'
)

CREATE TABLE currency (
  currency_id BIGINT,
  currency_name STRING,
  rate DOUBLE,
  currency_timestamp TIMESTAMP,
  country STRING,
  precise_timestamp TIMESTAMP(6),
  precise_time TIME(6),
  gdp DECIMAL(10, 6)
) WITH (
    'connector' = 'jdbc',
    'url' = 'jdbc:mysql://localhost:3306/flink',
    'username' = 'root',   
    'password' = '123456',
    'table-name' = 'currency',
    'driver' = 'com.mysql.jdbc.Driver',
    'lookup.cache.max-rows' = '500',
    'lookup.cache.ttl' = '10s',
    'sink.max-retries' = '3')
CREATE TABLE gmv (
  log_per_min STRING,
  item STRING,
  order_cnt BIGINT,
  currency_time TIMESTAMP(3),
  gmv DECIMAL(38, 18)) WITH (
  'connector' = 'kafka',
  'topic' = 'gmv',
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'format' = 'json',
  'scan.startup.mode' = 'earliest-offset'
)
insert into gmv
select cast(TUMBLE_END(o.order_time, INTERVAL '10' SECOND) as VARCHAR) as log_per_min,
 o.item, COUNT(o.order_id) as order_cnt, c.currency_timestamp,  cast(sum(o.amount_kg) * c.rate as DECIMAL(38, 18))  as gmv
 from orders as o
 join currency FOR SYSTEM_TIME AS OF o.proc_time c
 on o.currency = c.currency_name
 group by o.item, c.currency_timestamp, c.rate,TUMBLE(o.order_time, INTERVAL '10' SECOND)
