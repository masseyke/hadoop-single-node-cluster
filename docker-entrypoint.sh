#!/bin/bash

sudo service ssh start

if [ ! -d "/tmp/hadoop-hduser/dfs/name" ]; then
        $HADOOP_HOME/bin/hadoop namenode -format -force
fi
$HADOOP_HOME/bin/hadoop namenode -format -force

$HADOOP_HOME/bin/start-dfs.sh
#$HADOOP_HOME/sbin/start-yarn.sh

bash
