#!/bin/bash

: ${HADOOP_HOME:=/usr/local/hadoop}

$HADOOP_HOME/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

/etc/init.d/ssh start
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
$HADOOP_HOME/bin/mapred --daemon start historyserver

while true; do sleep 1000; done
