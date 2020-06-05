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
CREATE TABLE csvTest( 
    user_name STRING, 
    is_new BOOLEAN, 
    content STRING
) WITH ( 
    'connector' = 'filesystem',
    'path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/testKafka2CSVNewformat.csv',
    'format' = 'csv',
--    'update-mode' = 'append',
--    'format.fields.0.data-type' = 'STRING',
--    'format.fields.1.name' = 'is_new',
--    'format.fields.1.data-type' = 'BOOLEAN',
--    'format.fields.2.name' = 'content',
--    'format.fields.2.data-type' = 'STRING'
)
insert into csvTest select user_name, is_new, content from csvData

