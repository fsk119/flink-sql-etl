package kafka2kafka;

import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.Types;
import org.apache.flink.table.api.java.StreamTableEnvironment;
import org.apache.flink.table.functions.ScalarFunction;
import org.apache.flink.types.Row;

import constants.FlinkSqlConstants;

import java.math.BigDecimal;

public class KafkaJoinJdbc2Kafka {
    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);

        EnvironmentSettings envSettings = EnvironmentSettings.newInstance()
                .useBlinkPlanner()
                .inStreamingMode()
                .build();
        StreamTableEnvironment tableEnvironment = StreamTableEnvironment.create(env, envSettings);

        tableEnvironment.registerFunction("func", new Func());
        tableEnvironment.sqlUpdate(FlinkSqlConstants.ordersTableDDL);
        tableEnvironment.sqlUpdate(FlinkSqlConstants.mysqlCurrencyDDL);

        String sinkTableDDL = "CREATE TABLE gmv (\n" +
                "  log_per_min STRING,\n" +
                "  item STRING,\n" +
                "  order_cnt BIGINT,\n" +
                "  currency_time TIMESTAMP(3),\n" +
                "  gmv DECIMAL(38, 18)" +
                ") WITH (\n" +
                "  'connector.type' = 'kafka',\n" +
                "  'connector.version' = '0.10',\n" +
                "  'connector.topic' = 'gmv',\n" +
                "  'connector.properties.zookeeper.connect' = 'localhost:2181',\n" +
                "  'connector.properties.bootstrap.servers' = 'localhost:9092',\n" +
                "  'format.type' = 'json',\n" +
                "  'format.derive-schema' = 'true'\n" +
                ")";
        tableEnvironment.sqlUpdate(sinkTableDDL);

        String querySQL =
                "insert into gmv \n" +
                "select cast(TUMBLE_END(o.order_time, INTERVAL '10' SECOND) as VARCHAR) as log_per_min,\n" +
                " o.item, COUNT(o.order_id) as order_cnt, c.currency_time, " +
                " cast(sum(o.amount_kg) * c.rate as DECIMAL(38, 18))  as gmv \n" +
                " from orders as o \n" +
                " join currency FOR SYSTEM_TIME AS OF o.proc_time c\n" +
                " on o.currency = c.currency_name\n" +
                " group by o.item, c.currency_time,c.rate,TUMBLE(o.order_time, INTERVAL '10' SECOND)\n";

        tableEnvironment.sqlUpdate(querySQL);
        System.out.println(FlinkSqlConstants.ordersTableDDL);
        System.out.println(FlinkSqlConstants.mysqlCurrencyDDL);
        System.out.println(sinkTableDDL);
        System.out.println(querySQL);

        tableEnvironment.execute("KafkaJoinJdbc2Kafka.sql");
    }

    public static class Func extends ScalarFunction {
        public BigDecimal eval(BigDecimal amount) {
            return amount.multiply(new BigDecimal("100.0"));
        }

        @Override
        public TypeInformation<?> getResultType(Class<?>[] signature) {
            return Types.DECIMAL();
        }
    }
}
