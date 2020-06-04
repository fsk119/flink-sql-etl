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

CREATE TABLE upsert_estable(
    item STRING,
    num_order BIGINT,
    total_amount DOUBLE
) WITH (
    'connector' = 'elasticsearch-7',
    'hosts' = 'http://localhost:9200',
    'index' = 'upsert_orders',
    'document-id.key-delimiter' = '$',
    'sink.bulk-flush.interval' = '1000',
    'format' = 'json'
)

INSERT INTO upsert_estable 
SELECT item, count(order_id) as num_order, SUM(amount) as total_amount
FROM orders
GROUP BY item





  
