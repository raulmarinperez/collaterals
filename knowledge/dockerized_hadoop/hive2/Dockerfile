FROM hadoop3.2_vanilla
MAINTAINER raulmarinperez

USER root

# Download binaries and setup links, permissions and other attributes
RUN curl -s http://apache.rediris.es/hive/hive-2.3.5/apache-hive-2.3.5-bin.tar.gz | tar -xz -C /usr/local/
RUN curl -s http://apache.rediris.es/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz | tar -xz -C /usr/local/
RUN ln -s /usr/local/zeppelin-0.8.1-bin-all /usr/local/zeppelin
RUN ln -s /usr/local/apache-hive-2.3.5-bin /usr/local/hive2

## Hive 2 setup section
#
# Setup environment variables
ENV HIVE_HOME /usr/local/hive2

# Start dfs for a while to create some files in HDFS
RUN /etc/init.d/ssh start && \
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse && \
    $HADOOP_HOME/bin/hdfs dfs -chmod g+w /user/hive/warehouse && \
    $HADOOP_HOME/bin/hdfs dfs -chmod g+w /tmp && \
    $HADOOP_HOME/sbin/stop-dfs.sh

# Initialize Hive Metastore (Derby)
WORKDIR ${HIVE_HOME}
RUN $HIVE_HOME/bin/schematool -dbType derby -initSchema 

# Update core-site.xml to allow impersonation
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop

## Zeppelin setup section
#
# Setup environment variables
ENV ZEPPELIN_HOME /usr/local/zeppelin

# Hive interpreter setup
RUN ln -s $HIVE_HOME/lib/hive-exec-2.3.5.jar $ZEPPELIN_HOME/interpreter/jdbc
RUN ln -s $HIVE_HOME/lib/hive-jdbc-2.3.5.jar $ZEPPELIN_HOME/interpreter/jdbc
RUN ln -s $HIVE_HOME/lib/hive-service-2.3.5.jar $ZEPPELIN_HOME/interpreter/jdbc
RUN ln -s $HIVE_HOME/lib/libthrift-0.9.3.jar $ZEPPELIN_HOME/interpreter/jdbc
ADD interpreter.json $ZEPPELIN_HOME/conf

## Upload the main script for the container
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]

# Expose TCP ports to the outside world
EXPOSE 10000 8080
