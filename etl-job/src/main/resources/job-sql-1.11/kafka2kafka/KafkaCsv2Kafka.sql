-- from csv data to kafka
CREATE TABLE  csv(
    user_name VARCHAR, 
    is_new BOOLEAN, 
    content VARCHAR
) WITH ( 
    'connector' = 'filesystem',
    'path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/user.csv',
    'format' = 'csv'
)
CREATE TABLE csvData (
    user_name STRING,
    is_new    BOOLEAN,
    content STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'csv_data',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'csv'
)
insert into csvData
select user_name, is_new, content from
csv

-- from kafka to csv
CREATE TABLE csvData (
    user_name STRING,
    is_new    BOOLEAN,
    content STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'csv_data',
    'properties.bootstrap.servers' = 'localhost:9092',
    'properties.group.id' = 'testGroup4',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'csv'
)
-- NOTICE: If we want to flush data into file system, 
--         we must set checkpoint interval in flink-conf.yaml 
CREATE TABLE csvTest( 
    user_name STRING, 
    is_new BOOLEAN, 
    content STRING
) WITH ( 
    'connector' = 'filesystem',
    'path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/testKafka2CSVNewformat.csv',
    'format' = 'csv'
    'sink.partition-commit.delay'='0 s',
    'sink.partition-commit.policy.kind'='success-file',
    'sink.rolling-policy.time-interval'='10 s'
)
insert into csvTest select user_name, is_new, content from csvData

