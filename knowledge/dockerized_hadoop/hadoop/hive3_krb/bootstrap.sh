#!/bin/bash

RM_IMAGE_VERSION=3.1.1_0
RM_IMAGE_NAME="Hive 3_kerberized"
echo -e "\e[102mStarting $RM_IMAGE_NAME ($RM_IMAGE_VERSION) image...\e[0m"
sleep 5

: ${HADOOP_HOME:=/opt/hadoop}

$HADOOP_HOME/etc/hadoop/hadoop-env.sh

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
echo -e "  \e[32m    - Waiting for Name Node to be up.\e[0m"
kinit -kt /etc/security/keytab/dn.service.keytab dn/hadoop.krb.test@QUEEN.KRB.TEST
until hdfs dfs -chgrp hadoop /user; do
  sleep 5
done
echo -e "  \e[32m    - Changing permissions to reflect this new setup.\e[0m"
hdfs dfs -chgrp hadoop /user
hdfs dfs -chown -R hive:hadoop /user/hive
hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -chmod -R 777 /tmp
kdestroy

echo -e "  \e[32m  * Starting YARN.\e[0m"
$HADOOP_HOME/sbin/start-yarn.sh

echo -e "  \e[32m  * Starting the History server daemon.\e[0m"
sudo -u mapred $HADOOP_HOME/bin/mapred --daemon start historyserver

echo -e "  \e[32m  * Starting Hive Server2.\e[0m"
cd $HIVE_HOME; sudo -E -u hive $HIVE_HOME/bin/hiveserver2&

echo -e "  \e[32m  * Starting Zeppelin daemon.\e[0m"
cd $ZEPPELIN_HOME; sudo -E -u zeppelin $ZEPPELIN_HOME/bin/zeppelin-daemon.sh start

# Main loop
#

echo -e "\e[102mContainer in the main loop, enjoy the contents :)\e[0m"
while true; do sleep 1000; done
