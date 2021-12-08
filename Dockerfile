FROM ubuntu:18.04

RUN apt-get update -y && apt-get install vim -y && apt-get install wget -y && apt-get install ssh -y && apt-get install openjdk-8-jdk -y && apt-get install sudo -y && apt-get install curl -y
RUN useradd -m hduser && echo "hduser:supergroup" | chpasswd && adduser hduser sudo && echo "hduser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ && sudo ln -s python3 python

COPY ssh_config /etc/ssh/ssh_config

WORKDIR /home/hduser

USER hduser
RUN wget -q https://downloads.apache.org/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz && tar zxvf hadoop-3.3.0.tar.gz && rm hadoop-3.3.0.tar.gz
RUN wget -q https://dlcdn.apache.org/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz && tar zxvf spark-3.2.0-bin-hadoop3.2.tgz && rm spark-3.2.0-bin-hadoop3.2.tgz
RUN wget -q https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.16.0-linux-x86_64.tar.gz && tar zxvf elasticsearch-7.16.0-linux-x86_64.tar.gz && rm elasticsearch-7.16.0-linux-x86_64.tar.gz
RUN wget -q https://artifacts.elastic.co/downloads/kibana/kibana-7.16.0-linux-x86_64.tar.gz && tar zxvf kibana-7.16.0-linux-x86_64.tar.gz && rm kibana-7.16.0-linux-x86_64.tar.gz
RUN wget -q -O ./elasticsearch-spark-30_2.12-7.15.2.jar https://search.maven.org/remotecontent?filepath=org/elasticsearch/elasticsearch-spark-30_2.12/7.15.2/elasticsearch-spark-30_2.12-7.15.2.jar
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

ENV HDFS_NAMENODE_USER hduser
ENV HDFS_DATANODE_USER hduser
ENV HDFS_SECONDARYNAMENODE_USER hduser

ENV YARN_RESOURCEMANAGER_USER hduser
ENV YARN_NODEMANAGER_USER hduser

ENV HADOOP_HOME /home/hduser/hadoop-3.3.0
ENV HADOOP_CONF_DIR=/home/hduser/hadoop-3.3.0/etc/hadoop/
ENV ES_HOME /home/hduser/elasticsearch-7.16.0
ENV KIBANA_HOME /home/hduser/kibana-7.16.0-linux-x86_64
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN echo "server.host: 0.0.0.0" >> $KIBANA_HOME/config/kibana.yml
RUN echo 'alias es-spark="/home/hduser/spark-3.2.0-bin-hadoop3.2/bin/spark-shell --master yarn --deploy-mode client --jars /home/hduser/elasticsearch-spark-30_2.12-7.15.2.jar"' >> ~/.bashrc
RUN echo 'alias es-pyspark="/home/hduser/spark-3.2.0-bin-hadoop3.2/bin/pyspark --master yarn --deploy-mode client --jars /home/hduser/elasticsearch-spark-30_2.12-7.15.2.jar"' >> ~/.bashrc
COPY core-site.xml $HADOOP_HOME/etc/hadoop/
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/

COPY docker-entrypoint.sh $HADOOP_HOME/etc/hadoop/

ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22 9200 9300 5601

ENTRYPOINT ["/home/hduser/hadoop-3.3.0/etc/hadoop/docker-entrypoint.sh"]
