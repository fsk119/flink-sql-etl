CREATE DATABASE flink;
USE flink;
create table country(
  country_id bigint,
  counrty_name varchar(200),
  counrty_cn_name varchar(200),
  region_name varchar(200),
  primary key (`country_id`)
);

CREATE TABLE gmv (
  log_per_min varchar(200),
  item varchar(200),
  order_cnt BIGINT,
  currency_timestamp TIMESTAMP,
  gmv DECIMAL(38, 18),  precise_timestmap TIMESTAMP(6),
  precise_time TIME(6),
  gdp DECIMAL(38, 18),
  primary key(item)
);

CREATE TABLE currency (
    currency_id bigint(20) NOT NULL,
    currency_name varchar(200) DEFAULT NULL,
    rate double DEFAULT NULL,
    currency_timestamp TIMESTAMP DEFAULT NULL,
    country varchar(200),
    precise_timestamp TIMESTAMP(6),
    precise_time TIME(6),
    gdp DECIMAL(10, 6),
    PRIMARY KEY (currency_id)
) ;
INSERT INTO currency
VALUES (1, "Dollar", 102, NOW(), "America", NOW(6), CURTIME(6), ROUND(rand()*9999, 6)),
       (2, "Euro", 114, NOW(), "Europe", NOW(6), CURTIME(6), ROUND(rand()*9999, 6)),
       (3, "Yen", 1, NOW(), "Japan", NOW(6), CURTIME(6), ROUND(rand()*9999, 6)),
       (4, "RMB", 16, NOW(), "China", NOW(6), CURTIME(6), ROUND(rand()*9999,6));


