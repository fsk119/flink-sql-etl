## batch
create table csv( 
    pageId VARCHAR, eventId VARCHAR, recvTime VARCHAR
) with ( 'connector.type' = 'filesystem',
 'connector.path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/user3.csv',
 'format.type' = 'csv',
 'format.fields.0.name' = 'pageId',
 'format.fields.0.data-type' = 'STRING',
 'format.fields.1.name' = 'eventId',
 'format.fields.1.data-type' = 'STRING',
 'format.fields.2.name' = 'recvTime',
 'format.fields.2.data-type' = 'STRING')

CREATE TABLE es_table (
  aggId varchar ,
  pageId varchar ,
  ts varchar ,
  expoCnt int ,
  clkCnt int
) WITH (
'connector.type' = 'elasticsearch',
'connector.version' = '7',
'connector.hosts' = 'http://localhost:9200',
'connector.index' = 'cli_test',
'connector.document-type' = '_doc',
'update-mode' = 'upsert',
'connector.key-delimiter' = '$',
'connector.key-null-literal' = 'n/a',
'connector.bulk-flush.interval' = '1000',
'format.type' = 'json'
)
INSERT INTO es_table
  SELECT  pageId,eventId,cast(recvTime as varchar) as ts, 1, 1 from csv


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

CREATE TABLE es_orders(
    order_id STRING,
    item STRING, 
    order_time TIMESTAMP(3)
) WITH (
    'connector.type' = 'elasticsearch',
    'connector.version' = '7',
    'connector.hosts' = 'http://localhost:9200',
    'connector.index' = 'es_orders',
    'connector.document-type' = '_doc',
    'update-mode' = 'upsert',
    'connector.key-delimiter' = '$',
    'connector.key-null-literal' = 'n/a',
    'connector.bulk-flush.interval' = '1000',
    'format.type' = 'json'
)

insert into es_orders 
select order_id, item, order_time from orders;
