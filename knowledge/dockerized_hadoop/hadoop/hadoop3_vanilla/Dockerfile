# hadoop3_vanilla
#
# Description:
#   Docker image definition to run a Hadoop 3.2 pseudo cluster with no 
#   authentication nor authorization enabled.
#
#   Watch <replace by youtube URL> to see it in action.
#
#   NOTE: It doesn't rely on external volumes, which means once the container
#         is stopped ALL DATA IS GONE. This image is for testing and training
#         purposes.
#
# Build instructions:
#   docker build -t hadoop3_vanilla:<tag_name> .
#
# Container execution and access to services:
#  docker run -d --rm --hostname hadoop --name hadoop3 -p 8088:8088/tcp 
#             -p 19888:19888/tcp -p 50070:50070/tcp -p 50075:50075/tcp 
#             hadoop3_vanilla:<tag_name>
#  docker exec -it hadoop3 /bin/bash
#
# Release notes (tag names):
#   3.2_0 - Binaries deployed under /opt and daemons executed as root user
#

FROM base
MAINTAINER raulmarinperez

USER root

# Install software dependencies and setup environment:
#
#   - Update repo and install dependencies from the repo
#   - Download Hadoop 3.2 binaries and deploy them under /opt
#   - Setup environment variables for Hadoop and Java
#

#   Dependencies from the repo
RUN apt-get update -y
RUN apt-get install -y curl sudo openssh-server openssh-client rsync python nano less openjdk-8-jdk

#   Hadoop 3.2 binaries; deployment under /opt
RUN curl -s http://apache.rediris.es/hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz | tar -xz -C /opt
RUN cd /opt && ln -s ./hadoop-3.2.0 hadoop
RUN chown -R root:root /opt/hadoop-3.2.0/
RUN chmod +x /opt/hadoop/etc/hadoop/*-env.sh

#   Environment variables setup
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_COMMON_HOME /opt/hadoop
ENV HADOOP_HDFS_HOME /opt/hadoop
ENV HADOOP_MAPRED_HOME /opt/hadoop
ENV HADOOP_YARN_HOME /opt/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HDFS_DATANODE_USER root
ENV HDFS_NAMENODE_USER root 
ENV HDFS_SECONDARYNAMENODE_USER root 
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

RUN sed -i '/^# export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport HADOOP_HOME=/opt/hadoop\nexport HADOOP_HOME=/opt/hadoop\n:' $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN sed -i '/^# export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop:' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Setup passwordless SSH (exit 0 needed to avoid non-zero code: 1 error due to existing files)
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key; exit 0
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key; exit 0
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa; exit 0
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# Hadoop 3.2 initial setup and HDFS initialization:
#
#   - Add configurations files for pseudo-distributed setup
#   - Create local folders for HDFS
#   - Name node formatting and creation of a couple of HDFS folders
#

#   Configuration file for pseudo-distributed setup
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/core-site.xml.template
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

#   Local folders for HDFS
RUN mkdir -p /data/hdfs/namenode
RUN mkdir -p /data/hdfs/datanode
RUN chown root:root -R /data

#   Name node formatting and HDFS folders creation (HDFS needs to be brought 
#   up for a while)
RUN $HADOOP_HOME/bin/hdfs namenode -format
RUN sed s/HOSTNAME/localhost/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml
RUN /etc/init.d/ssh start && \
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -chown hdfs:hadoop / && \
    $HADOOP_HOME/bin/hdfs dfs -chmod 755 / && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
    $HADOOP_HOME/bin/hdfs dfs -chown hdfs:hadoop /user && \
    $HADOOP_HOME/bin/hdfs dfs -chmod 755 /user && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir /tmp && \
    $HADOOP_HOME/bin/hdfs dfs -chmod 777 /tmp && \
    $HADOOP_HOME/bin/hdfs dfs -chown hdfs:hadoop /tmp && \
    $HADOOP_HOME/sbin/stop-dfs.sh

# Main script to initialize the container with Hadoop 3 services
#

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

WORKDIR /opt/hadoop
CMD ["/etc/bootstrap.sh"]

# Expose TCP ports to the outside world:
#
#   - HDFS - Name node + Data node
#   - MR/YARN - Resource manager + MR JobHistory server
#

#   HDFS - Name node + Data node
EXPOSE 50070 50075
#   MR/YARN - Resource manager + MR JobHistory server
EXPOSE 8088 19888
