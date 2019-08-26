# hive3_krb
# 
# Description:
#   A Hive3 Docker image built on top of the hive3 image and using the setup of
#   the hadoop3_krb image as a reference to bring Kerberos to this one; Even
#   though Kerberos authentication is enabled, it's still a functional artifact
#   and it has to be used for testing and training. Execution engine is MR.
#   Zeppelin has been also included to facilitate interaction with Hive.
#
#   Additionally, it includes data from the Hortonia Bank demo which can be
#   handy to play around with some data. This content is available on the
#   Internet:
#
#   https://github.com/abajwa-hw/masterclass/tree/master/ranger-atlas
#
#   Watch <replace by youtube URL> to see it in action.
#
#   NOTE: It doesn't rely on external volumes, which means once the container
#         is stopped ALL DATA IS GONE. This image is for testing and training
#         purposes.
#
# Build instructions:
#   docker build -t hive3_krb:<tag_name> .
#
# Container execution and access to services:
#  docker run -d --rm --hostname hadoop --domainname krb.test  --name hive3 --privileged -p 8088:8088/tcp
#             -p 19888:19888/tcp -p 50070:50070/tcp -p 50075:50075/tcp
#             -p 10000:10000/tcp -p 8080:8080/tcp -p 88:88/tcp -p 750:750/udp
#             hive3_krb:<tag_name>
#  docker exec -it hive3 /bin/bash
#
# Release notes (tag names):
#   3.1.1_0 - Binaries deployed under /opt and daemons executed as hive and
#             zeppelin users respectively.
#

FROM hive3
MAINTAINER raulmarinperez

# KERBEROS SETUP SECTION
#

# Install software and setup environment:
#
#   - Update repo and install software from the repo
#   - Replace configuration files with the custom ones
#   - Add realm initialization scripts to root's home
#

#   Update repo and install software from the repo
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y
RUN apt-get install -yq expect krb5-kdc krb5-admin-server krb5-user jsvc

#   Update repo and install software from the repo
ADD kerberos/krb5.conf /etc/krb5.conf
ADD kerberos/kdc.conf /etc/krb5kdc
ADD kerberos/kadm5.acl /etc/krb5kdc

#   Add realm initialization scripts to root's home
ADD kerberos/script_create_krb5_db.exp /root
ADD kerberos/script_add_admin_into_krb5_db.exp /root

# Create Kerberos database and admin/admin@QUEEN.KRB.TEST principal.
#

RUN expect -f /root/script_create_krb5_db.exp
RUN expect -f /root/script_add_admin_into_krb5_db.exp

# HADOOP SETUP SECTION
#

# System level additional configurations:
#
#   - Create users for Hadoop services: hdfs, yarn and mapred
#   - SSH passwordless setup:
#     * Generate keys for each user
#     * Add ssh_config file to each user and set proper permissions
#

#    Create users for Hadoop services: hdfs, yarn and mapred
RUN addgroup hadoop && \
    useradd -N -m -s /bin/bash -G hadoop hdfs && \
    useradd -N -m -s /bin/bash -G hadoop yarn && \
    useradd -N -m -s /bin/bash -G hadoop mapred && \
    useradd -N -m -s /bin/bash -G hadoop hive && \
    useradd -N -m -s /bin/bash -G hadoop zeppelin && \
    #    Provide system users with passwords
    echo 'hdfs:hdfs123' | chpasswd && \
    echo 'yarn:yarn123' | chpasswd && \
    echo 'mapred:mapred123' | chpasswd && \
    echo 'hive:hive123' | chpasswd && \
    echo 'zeppelin:zeppelin123' | chpasswd

#    SSH passwordless setup:
#      Generate keys for each user
USER hdfs
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t rsa -f /home/hdfs/.ssh/id_rsa; exit 0
RUN cp /home/hdfs/.ssh/id_rsa.pub /home/hdfs/.ssh/authorized_keys
USER yarn
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t rsa -f /home/yarn/.ssh/id_rsa; exit 0
RUN cp /home/yarn/.ssh/id_rsa.pub /home/yarn/.ssh/authorized_keys
USER mapred
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t rsa -f /home/mapred/.ssh/id_rsa; exit 0
RUN cp /home/mapred/.ssh/id_rsa.pub /home/mapred/.ssh/authorized_keys

#      Add ssh_config file to each user and set proper permissions
USER root
ADD hadoop/ssh_config /home/hdfs/.ssh/config
ADD hadoop/ssh_config /home/yarn/.ssh/config
ADD hadoop/ssh_config /home/mapred/.ssh/config
RUN chmod 600 /home/hdfs/.ssh/config && \
    chown hdfs:hadoop /home/hdfs/.ssh/config && \
    chmod 600 /home/yarn/.ssh/config && \
    chown yarn:hadoop /home/yarn/.ssh/config && \
    chmod 600 /home/mapred/.ssh/config && \
    chown mapred:hadoop /home/mapred/.ssh/config

# Build kerberized infra:
#
#   - Create folders and copy scripts to generate keytabs
#   - Scripts execution
#   - Set proper permissions
#

#   Create folders and copy scripts to generate keytabs
RUN mkdir -p /etc/security/keytab && \
    mkdir -p /root/scripts
ADD hadoop/*exp /root/scripts/

#   Scripts execution
RUN expect -f /root/scripts/nn_principal.script.exp && \
    expect -f /root/scripts/sn_principal.script.exp && \
    expect -f /root/scripts/dn_principal.script.exp && \
    expect -f /root/scripts/spnego_principal.script.exp && \
    expect -f /root/scripts/rm_principal.script.exp && \
    expect -f /root/scripts/nm_principal.script.exp && \
    expect -f /root/scripts/jhs_principal.script.exp && \
    expect -f /root/scripts/hive_principal.script.exp && \
    expect -f /root/scripts/zeppelin_principal.script.exp

RUN chown hdfs /etc/security/keytab/dn.service.keytab && \
    chown hdfs /etc/security/keytab/nn.service.keytab && \
    chown hdfs /etc/security/keytab/sn.service.keytab && \
    chown hdfs /etc/security/keytab/spnego.service.keytab && \
    chown yarn /etc/security/keytab/nm.service.keytab && \
    chown yarn /etc/security/keytab/rm.service.keytab && \
    chown mapred /etc/security/keytab/jhs.service.keytab && \
    chown hive /etc/security/keytab/hive.service.keytab && \
    chown zeppelin /etc/security/keytab/zeppelin.service.keytab

# Configure Hadoop to run it in secure mode (only Kerberos):
#
#   - Copy customized configuration files
#   - HDFS-related local files review
#   - YARN-related files review
#   - Hadoop-wise files review
#   - Env variable to define OS users for Hadoop services
#

#   Copy configuration files
ADD hadoop/hadoop-env.sh $HADOOP_HOME/etc/hadoop
ADD hadoop/core-site.xml $HADOOP_HOME/etc/hadoop
ADD hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop
ADD hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop
ADD hadoop/container-executor.cfg $HADOOP_HOME/etc/hadoop
ADD hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop
ADD hadoop/hive-site.xml $HIVE_HOME/conf
ADD hadoop/interpreter.json $ZEPPELIN_HOME/conf

#   HDFS-related local files review
RUN chown -R hdfs:hadoop /data/hdfs/ && \
    chmod 700 /data/hdfs/namenode && \
    chmod 700 /data/hdfs/datanode

#   YARN-related files review
RUN mkdir -p /data/yarn/local && \
    mkdir -p /data/yarn/logs && \
    chown root:hadoop $HADOOP_HOME/bin/container-executor && \
    chmod 6050 $HADOOP_HOME/bin/container-executor && \
    chown root:hadoop $HADOOP_HOME/etc/hadoop/container-executor.cfg && \
    chmod 400 $HADOOP_HOME/etc/hadoop/container-executor.cfg && \
    chown -R yarn:hadoop /data/yarn/ && \
    chmod 755 /data/yarn/local && \
    chmod 755 /data/yarn/logs

#   Hive and Zeppelin-related files review
RUN chown -R hive:hadoop /opt/apache-hive-3.1.1-bin && \
    chown -R zeppelin:hadoop /opt/zeppelin-0.8.1-bin-all

#   Hadoop-wise files review
RUN chown hdfs:hadoop $HADOOP_HOME/logs && \
    chmod 775 $HADOOP_HOME/logs && \
    chmod 777 $HADOOP_HOME/logs/fairscheduler-statedump.log && \
    chmod 755 $HADOOP_HOME/etc/hadoop/hadoop-env.sh

#   Env variable to define OS users for Hadoop services
ENV HDFS_DATANODE_USER root
ENV HDFS_NAMENODE_USER hdfs
ENV HDFS_SECONDARYNAMENODE_USER hdfs
ENV YARN_RESOURCEMANAGER_USER yarn
ENV YARN_NODEMANAGER_USER yarn

# Main script to initialize the container with Hadoop 3 services
#

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

WORKDIR /opt/hadoop
CMD ["/etc/bootstrap.sh"]

# Expose Kerberos ports to the outside world
#
#   KERBEROS - 88(tcp) and 750(udp)

EXPOSE 88 750

# Some links I found useful while building this file:
#
#   - Setting up HiverServer2:
#     https://cwiki.apache.org/confluence/display/Hive/Setting+up+HiveServer2
#   - Configure HiveServer 2 to use Kerberos:
#     https://mapr.com/docs/52/Hive/HiveServer2-KerberosAuth.html
#   - HiveServer2 Clients:
#     https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients#HiveServer2Clients-BeelineExample
#   - Generic JDBC Interpreter for Apache Zeppelin:
#     https://zeppelin.apache.org/docs/latest/interpreter/jdbc.html#apache-hive
#   - AuthenticationMethod exception on JDBC interpreter:
#     https://issues.apache.org/jira/browse/ZEPPELIN-1326
#   - How to check the namenode status?:
#     https://community.cloudera.com/t5/Support-Questions/How-to-check-the-namenode-status/m-p/149546
#   - kinit: krb5_get_init_creds: unable to reach any KDC in realm LOCAL:
#     https://apple.stackexchange.com/questions/63122/kinit-krb5-get-init-creds-unable-to-reach-any-kdc-in-realm-local