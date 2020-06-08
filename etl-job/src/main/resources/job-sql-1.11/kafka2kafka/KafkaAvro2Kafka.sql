-- first job: build avro format data from csv and write to kafka nqtopic
CREATE TBALE csv( 
  user_name VARCHAR, 
  is_new BOOLEAN, 
  content VARCHAR
) WITH ( 
  'connector' = 'filesystem',
  'path' = '/Users/ohmeatball/Work/flink-sql-etl/data-generator/src/main/resources/user.csv',
  'format' = 'csv'
)

CREATE TABLE AvroTest (
  user_name VARCHAR,
  is_new BOOLEAN,
  content VARCHAR
) WITH (
  'connector' = 'kafka',
  'topic' = 'avro_from_csv',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'avro')

insert into AvroTest select user_name, is_new, content from csv

-- second job: consume avro format data from kafka and write to another kafka topic

CREATE TABLE AvroTest (
  user_name VARCHAR,
  is_new BOOLEAN,
  content VARCHAR
) WITH (
  'connector' = 'kafka',
  'topic' = 'avro_from_csv',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup4',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'avro'
)

CREATE TABLE WikipediaFeed_filtered (
  user_name STRING,
  is_new    BOOLEAN,
  content STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'WikipediaFeed2_filtered',
  'properties.bootstrap.servers' = 'localhost:9092',
  'properties.group.id' = 'testGroup3',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'avro'
)
INSERT INTO  WikipediaFeed_filtered
SELECT user_name, is_new, content
FROM AvroTest
