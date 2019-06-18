FROM base
MAINTAINER raulmarinperez

USER root

# Install dependencies
#
RUN apt-get update -y
RUN apt-get install -y curl sudo openssh-server openssh-client rsync python nano

# Create users for the different services
#
RUN useradd hadoop
RUN useradd hdfs

# Create folder for keeping HDFS data
#
RUN mkdir -p /data/hdfs/namenode
RUN mkdir -p /data/hdfs/datanode

# Setup passwordless SSH (exit 0 needed to avoid non-zero code: 1 error due to existing files)
#
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key; exit 0
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key; exit 0
RUN echo -e 'y\n' | ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa; exit 0
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# Install and configure Java
#
RUN apt-get install -y openjdk-8-jdk
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin

# Deploy Hadoop
#

# Download binaries and setup links, permissions and other attributes
RUN curl -s http://apache.rediris.es/hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-3.2.0 hadoop
RUN chown -R hadoop:hadoop /usr/local/hadoop-3.2.0/
RUN chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh

# Setup environment variables
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV HDFS_DATANODE_USER root
ENV HDFS_DATANODE_SECURE_USER hdfs 
ENV HDFS_NAMENODE_USER root 
ENV HDFS_SECONDARYNAMENODE_USER root 
ENV YARN_RESOURCEMANAGER_USER root
ENV YARN_NODEMANAGER_USER root
ENV PATH $PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN sed -i '/^# export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\nexport HADOOP_HOME=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_HOME/etc/hadoop/hadoop-env.sh
RUN sed -i '/^# export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop:' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Add configurations files for pseudo-distributed setup
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop/core-site.xml.template
RUN sed s/HOSTNAME/localhost/ $HADOOP_HOME/etc/hadoop/core-site.xml.template > $HADOOP_HOME/etc/hadoop/core-site.xml
ADD hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

# Name node formatting (/data/hdfs/namenode)
RUN $HADOOP_HOME/bin/hdfs namenode -format

# Start dfs for a while to create some files in HDFS
RUN /etc/init.d/ssh start && \
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root && \
    $HADOOP_HOME/sbin/stop-dfs.sh

## Upload the main script for the container
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]

# Expose TCP ports to the outside world
#

# HDFS - Name node + Data node
EXPOSE 50070 50075
# MR/YARN - Resource manager + MR JobHistory server
EXPOSE 8088 19888
# Others - SSH
EXPOSE 22
