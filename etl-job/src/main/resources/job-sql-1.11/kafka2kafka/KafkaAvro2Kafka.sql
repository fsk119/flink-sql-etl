-- first job: build avro format data from csv and write to kafka topic
create table csv( 
    user_name VARCHAR, is_new BOOLEAN, content VARCHAR
) with ( 
    'connector' = 'filesystem',
    'path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/user.csv',
    'format' = 'csv')
--BUG: it will throw NPE: FLINK-1940
CREATE TABLE AvroTest (
  user_name VARCHAR,
  is_new BOOLEAN,
  content VARCHAR) WITH (
  'connector' = 'kafka',
  'topic' = 'avro_from_csv',
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'avro')

insert into AvroTest select user_name, is_new, content from csv

-- second job: consume avro format data from kafka and write to another kafka topic

CREATE TABLE AvroTest (
  user_name VARCHAR,
  is_new BOOLEAN,
  content VARCHAR) WITH (
  'connector' = 'kafka',
  'topic' = 'avro_from_csv',
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup4',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'avro'
)

CREATE TABLE WikipediaFeed_filtered (
  user_name STRING,
  is_new    BOOLEAN,
  content STRING) WITH (
  'connector' = 'kafka',
  'topic' = 'WikipediaFeed2_filtered',
  'properties.zookeeper.connect' = 'localhost:2181',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'avro')
insert into WikipediaFeed_filtered
select user_name, is_new, content
from AvroTest
