FROM ubuntu:18.04

RUN apt-get update -y && apt-get install vim -y && apt-get install wget -y && apt-get install ssh -y && apt-get install openjdk-8-jdk -y && apt-get install sudo -y
RUN useradd -m hduser && echo "hduser:supergroup" | chpasswd && adduser hduser sudo && echo "hduser     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && cd /usr/bin/ && sudo ln -s python3 python

COPY ssh_config /etc/ssh/ssh_config

WORKDIR /home/hduser

USER hduser
RUN wget -q https://archive.apache.org/dist/hadoop/core/hadoop-1.2.1/hadoop-1.2.1.tar.gz && tar zxvf hadoop-1.2.1.tar.gz && rm hadoop-1.2.1.tar.gz
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 0600 ~/.ssh/authorized_keys

ENV HDFS_NAMENODE_USER hduser
ENV HDFS_DATANODE_USER hduser
ENV HDFS_SECONDARYNAMENODE_USER hduser

ENV YARN_RESOURCEMANAGER_USER hduser
ENV YARN_NODEMANAGER_USER hduser

ENV HADOOP_HOME /home/hduser/hadoop-1.2.1
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> $HADOOP_HOME/conf/hadoop-env.sh
COPY core-site.xml $HADOOP_HOME/conf/
COPY hdfs-site.xml $HADOOP_HOME/conf/
COPY yarn-site.xml $HADOOP_HOME/conf/

COPY docker-entrypoint.sh $HADOOP_HOME/conf/

ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN mkdir -p /tmp/hadoop-hduser/dfs/name

RUN keytool -genkey -keyalg RSA -keysize 1024 -dname "CN=localhost,OU=hw,O=hw,L=paloalto,ST=ca,C=us" -keypass a123456 -keystore ./.keystore -storepass a123456 -alias localhost
RUN keytool -export -alias localhost -keystore ./.keystore -rfc -file ./fake.cert -storepass a123456
RUN keytool -export -alias localhost -keystore ./.keystore -rfc -file ./fake.cert -storepass a123456
RUN keytool -import -noprompt -alias localhost -file ./fake.cert  -keystore ./truststore -storepass a123456
RUN keytool -import -noprompt -alias localhost -file ./fake.cert -keystore all.jks -storepass a123456

EXPOSE 50070 50075 50010 50020 50090 8020 9000 9864 9870 10020 19888 8088 8030 8031 8032 8033 8040 8042 22

ENTRYPOINT ["/home/hduser/hadoop-1.2.1/conf/docker-entrypoint.sh"]
