FROM maven:3.6-jdk-8-slim AS builder

RUN mkdir -p /opt/datagen
COPY log4j.properties /opt/datagen
COPY flink-sql-test.jar /opt/datagen
WORKDIR /opt/datagen

ENV DATEGEN_HOME /opt/datagen

