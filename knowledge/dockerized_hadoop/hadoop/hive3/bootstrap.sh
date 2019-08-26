#!/bin/bash

RM_IMAGE_VERSION=3.1.1_0
RM_IMAGE_NAME="Hive 3 (no auth, MR execution engine)"
echo -e "\e[102mStarting $RM_IMAGE_NAME $RM_IMAGE_VERSION image...\e[0m"
sleep 5

# Environment setup:
#   - Execute hadoop-env.sh script
#

echo -e "  \e[32m  * Execution of hadoop-env.sh to setup all the environment variables for Hadoop.\e[0m"
: ${HADOOP_HOME:=/usr/local/hadoop}
$HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Starting system and Hadoop services:
#   - Starting SSH
#   - Starting HDFS
#   - Starting YARN
#   - Starting the History server daemon
#   - Starting Hive server2 (wait some seconds for it - Zeppelin's Hive 
#       interpreter will fail if it starts before Hive server2)
#   - Starting Zeppelin daemon
#

echo -e "  \e[32m  * Starting the SSH server.\e[0m"
/etc/init.d/ssh start
echo -e "  \e[32m  * Starting HDFS.\e[0m"
$HADOOP_HOME/sbin/start-dfs.sh
echo -e "  \e[32m  * Starting YARN.\e[0m"
$HADOOP_HOME/sbin/start-yarn.sh
echo -e "  \e[32m  * Starting the History server daemon.\e[0m"
$HADOOP_HOME/bin/mapred --daemon start historyserver
echo -e "  \e[32m  * Starting Hive server2\e[0m"
cd $HIVE_HOME; $HIVE_HOME/bin/hiveserver2&
sleep 5 
echo -e "  \e[32m  * Starting Zeppelin daemon.\e[0m"
$ZEPPELIN_HOME/bin/zeppelin-daemon.sh start

# Main loop
#

echo -e "\e[102mContainer in the main loop, enjoy the contents :)\e[0m"
while true; do sleep 1000; done
