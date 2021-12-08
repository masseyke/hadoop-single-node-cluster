#!/bin/bash

sudo service ssh start

if [ ! -d "/tmp/hadoop-hduser/dfs/name" ]; then
        $HADOOP_HOME/bin/hdfs namenode -format
fi

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
nohup $ES_HOME/bin/elasticsearch &> elasticsearch.out &
nohup $KIBANA_HOME/bin/kibana &> kibana.out &

bash
