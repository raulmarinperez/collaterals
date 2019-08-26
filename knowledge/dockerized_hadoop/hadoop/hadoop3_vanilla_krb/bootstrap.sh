#!/bin/bash

RM_IMAGE_VERSION=3.2_0
RM_IMAGE_NAME="Hadoop 3"
echo -e "\e[102mStarting $RM_IMAGE_NAME ($RM_IMAGE_VERSION) image...\e[0m"
sleep 5

#: ${HADOOP_HOME:=/opt/hadoop}

#$HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Starting services:
#   - Starting KDC server
#   - Starting Kerberos Admin server
#   - Starting SSH
#   - Starting HDFS
#   - Starting YARN
#   - Starting the History server daemon
#

echo -e "  \e[32m  * Starting KDC server.\e[0m"
krb5kdc
echo -e "  \e[32m  * Starting Kerberos Admin server.\e[0m"
kadmind

echo -e "  \e[32m  * Starting the SSH server.\e[0m"
/etc/init.d/ssh start
echo -e "  \e[32m  * Starting HDFS.\e[0m"
$HADOOP_HOME/sbin/start-dfs.sh
echo -e "  \e[32m    - Updating some default permissions for this new setup.\e[0m"
kinit -kt /etc/security/keytab/dn.service.keytab dn/hadoop.krb.test@QUEEN.KRB.TEST
hdfs dfs -chgrp hadoop /user
hdfs dfs -chmod -R 777 /tmp
kdestroy
echo -e "  \e[32m  * Starting YARN.\e[0m"
$HADOOP_HOME/sbin/start-yarn.sh
echo -e "  \e[32m  * Starting the History server daemon.\e[0m"
sudo -u mapred $HADOOP_HOME/bin/mapred --daemon start historyserver

# Main loop
#

echo -e "\e[102mContainer in the main loop, enjoy the contents :)\e[0m"
while true; do sleep 1000; done
