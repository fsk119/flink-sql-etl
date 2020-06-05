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
  currency_timestamp  TIMESTAMP(3),
  country STRING,
  precise_timestamp TIMESTAMP(6),
  precise_time TIME(3),
  gdp DECIMAL(38, 18)
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

CREATE TABLE gmv_with_pk (
    log_per_min STRING,
    item STRING,
    order_cnt BIGINT,
    currency_timestamp TIMESTAMP(3),
    gmv DECIMAL(38, 18),  precise_timestamp TIMESTAMP(6),
    precise_time TIME(6),
    gdp  DECIMAL(38, 18),
    PRIMARY KEY(item) NOT ENFORCED
) WITH (
   'connector' = 'jdbc',
   'url' = 'jdbc:mysql://localhost:3306/flink',
   'username' = 'root',
   'password' = '123456',
   'table-name' = 'gmv_with_pk',
   'driver' = 'com.mysql.jdbc.Driver',
   'sink.buffer-flush.max-rows' = '5000',
   'sink.buffer-flush.interval' = '2',
   'sink.max-retries' = '3')

insert into gmv_with_pk
    select
        max(log_ts),
        item, 
        COUNT(*) as order_cnt, 
        max(currency_time), 
        cast(sum(amount_kg) * max(rate) as DOUBLE)  as gmv,
        max(precise_timestamp), max(precise_time),  max(gdp)
    from (
        select 
            cast(o.ts as VARCHAR) as log_ts, 
            o.item as item, 
            o.order_id as order_id, 
            c.currency_timestamp as currency_time,
            o.amount_kg as amount_kg, 
            c.rate as rate, 
            c.precise_timestamp as precise_timestamp, 
            c.precise_time as precise_time, c.gdp as gdp
        from orders as o
        join currency FOR SYSTEM_TIME AS OF o.proc_time c
        on o.currency = c.currency_name
    ) a 
    group by item


