CREATE TABLE orders (
  order_id STRING,
  item    STRING,
  currency STRING,
  amount DOUBLE,
  order_time TIMESTAMP(3),
  proc_time as PROCTIME(),
  amount_kg as amount * 1000,
  ts as order_time + INTERVAL '1' SECOND,
  WATERMARK FOR order_time AS order_time) WITH (
  'connector' = 'kafka',
  'topic' = 'orders',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'json')

CREATE TABLE order_cnt (
  log_per_min TIMESTAMP(3),
  item STRING,
  order_cnt BIGINT,
  total_quality BIGINT
) WITH (
  'connector' = 'kafka',
  'topic' = 'order_cnt',
  'properties.bootstrap.servers' = 'localhost:9092',
  'format' = 'json',
  'scan.startup.mode' = 'earliest-offset'
)
insert into order_cnt
select TUMBLE_END(order_time, INTERVAL '10' SECOND),
 item, COUNT(order_id) as order_cnt, CAST(sum(amount_kg) as BIGINT) as total_quality
from orders
group by item, TUMBLE(order_time, INTERVAL '10' SECOND)
