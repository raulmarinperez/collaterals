#!/bin/bash

RM_IMAGE_VERSION=3.2_0
RM_IMAGE_NAME="Hadoop 3 vanilla"
echo -e "\e[102mStarting $RM_IMAGE_NAME $RM_IMAGE_VERSION image...\e[0m"
sleep 5

# Environment setup:
#   - Execute hadoop-env.sh script
#   - Update the hostname in the core-site.xml file
#

echo -e "  \e[32m  * Execution of hadoop-env.sh to setup all the environment variables for Hadoop.\e[0m"
: ${HADOOP_HOME:=/opt/hadoop}
$HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo -e "  \e[32m  * Replacing the hostname in core-site.xml.\e[0m"
sed s/HOSTNAME/$HOSTNAME/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml

# Starting system and Hadoop services:
#   - Starting SSH
#   - Starting HDFS
#   - Starting YARN
#   - Starting the History server daemon
#

echo -e "  \e[32m  * Starting the SSH server.\e[0m"
/etc/init.d/ssh start
echo -e "  \e[32m  * Starting HDFS.\e[0m"
$HADOOP_HOME/sbin/start-dfs.sh
echo -e "  \e[32m  * Starting YARN.\e[0m"
$HADOOP_HOME/sbin/start-yarn.sh
echo -e "  \e[32m  * Starting the History server daemon.\e[0m"
$HADOOP_HOME/bin/mapred --daemon start historyserver

# Main loop
#

echo -e "\e[102mContainer in the main loop, enjoy the contents :)\e[0m"
while true; do sleep 1000; done
