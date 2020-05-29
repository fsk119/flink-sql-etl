-- from csv data to kafka
create table csv( 
    user_name VARCHAR, is_new BOOLEAN, content VARCHAR
) with (
    'connector' = 'filesystem',
    'path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/user.csv',
    'format' = 'csv')
CREATE TABLE csvData (
  user_name STRING,
  is_new    BOOLEAN,
  content STRING) WITH (
  'connector' = 'kafka',
  'topic' = 'csv_data',
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'csv')
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
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup4',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'csv')
create table csvTest( user_name VARCHAR, is_new BOOLEAN, content VARCHAR) with ( 'connector.type' = 'filesystem',
 'connector.path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/testKafka2CSV.csv',
 'format.type' = 'csv',
 'update-mode' = 'append',
 'format.fields.0.name' = 'user_name',
 'format.fields.0.data-type' = 'STRING',
 'format.fields.1.name' = 'is_new',
 'format.fields.1.data-type' = 'BOOLEAN',
 'format.fields.2.name' = 'content',
 'format.fields.2.data-type' = 'STRING')
insert into csvTest select user_name, is_new, content from csvData

