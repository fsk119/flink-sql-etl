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

CREATE TABLE append_orders (
    order_id STRING,
    item STRING,
    currency STRING,
    amount DOUBLE,
    order_time TIMESTAMP(3),
    proc_time as PROCTIME(),
    amount_kg as amount * 1000
) WITH (
    'connector.type' = 'elasticsearch',
    'connector.version' = '7',
    'connector.hosts' = 'http://localhost:9200',
    'connector.index' = 'dynamic-index-{order_id}',
    'connector.document-type' = '_doc',
    'update-mode' = 'upsert',
    'connector.key-delimiter' = '$',
    'connector.key-null-literal' = 'n/a',
    'connector.bulk-flush.interval' = '1000',
    'format.type' = 'json' 
)
INSERT INTO append_orders
SELECT order_id, item, currency, amount, order_time
FROM orders; 


