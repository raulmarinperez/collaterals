# hadoop3_vanilla_krb
# 
# Description:
#   Kerberized version of the the Hadoop 3.2 pseudo cluster Docker image;
#   QUEEN.KRB.TEST is the name of the realm where the pseudo cluster belongs to.
#
#   Watch <replace by youtube URL> to see it in action.
#
#   NOTE: It doesn't rely on external volumes, which means once the container
#         is stopped ALL DATA IS GONE. This image is for testing and training
#         purposes.
#
# Build instructions:
#   docker build -t hadoop3_vanilla_krb:<tag_name> .
#
# Container execution and access to services:
#  docker run -d --rm --hostname hadoop --domainname krb.test --name hadoop3 --privileged 
#             -p 8088:8088/tcp -p 19888:19888/tcp -p 50070:50070/tcp 
#             -p 50075:50075/tcp hadoop3_vanilla_krb:<tag_name>
#  docker exec -it hadoop3 /bin/bash
#
# Release notes (tag names):
#   3.2_0 - Binaries deployed under /opt and daemons executed as root user
#

FROM hadoop3_vanilla
MAINTAINER raulmarinperez

USER root

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
    useradd -N -m -s /bin/bash -G hadoop raul && \
    #    Provide system users with passwords
    echo 'hdfs:hdfs123' | chpasswd && \
    echo 'yarn:yarn123' | chpasswd && \
    echo 'mapred:mapred123' | chpasswd && \
    echo 'raul:raul123' | chpasswd

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
    expect -f /root/scripts/raul_principal.script.exp

RUN chown hdfs /etc/security/keytab/dn.service.keytab && \
    chown hdfs /etc/security/keytab/nn.service.keytab && \
    chown hdfs /etc/security/keytab/sn.service.keytab && \
    chown hdfs /etc/security/keytab/spnego.service.keytab && \
    chown yarn /etc/security/keytab/nm.service.keytab && \
    chown yarn /etc/security/keytab/rm.service.keytab && \
    chown mapred /etc/security/keytab/jhs.service.keytab

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

#   Hadoop-wise files review
RUN chown hdfs:hadoop $HADOOP_HOME/logs && \
    chmod 775 $HADOOP_HOME/logs

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

# Some links I found useful while building this file:
#
#   - Cannot set priority of datanode process:
#       http://mail-archives.apache.org/mod_mbox/hadoop-hdfs-dev/201804.mbox/browser
#       https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities
#   - NodeManager fails to start in a secured cluster:
#       https://community.pivotal.io/s/article/Nodemanager-fails-to-start-in-a-secured-cluster
#   - Hadoop in Secure Mode:
#       https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SecureMode.html
#       https://unix.stackexchange.com/questions/108718/what-is-chmod-6050-good-for
#   - YARN Secure Containers:
#       https://hadoop.apache.org/docs/r2.7.2/hadoop-yarn/hadoop-yarn-site/SecureContainer.html
# 
#   Links below where handy when I tried having two containers (krb5 and
#   hadoop) running at the same time, which needs to define the networking
#   properly:
#
#   - Set specific IP addresses to docker containers created with docker-compose:
#       https://blog.alejandrocelaya.com/2017/04/21/set-specific-ip-addresses-to-docker-containers-created-with-docker-compose/
#   - Docker Networking Design Philosophy:
#       https://blog.docker.com/2016/03/docker-networking-design-philosophy/
#   - 