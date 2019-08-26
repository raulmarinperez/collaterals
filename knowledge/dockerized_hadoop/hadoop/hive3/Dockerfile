# hive3
# 
# Description:
#   A Hive3 Docker image built on top of the Hadoop3_vanilla image; it's a
#   functional artifact as it doesn't have any advanced feature, such as
#   authentication or authorization, enabled. Execution engine is MR. 
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
#   docker build -t hive3:<tag_name> .
#
# Container execution and access to services:
#  docker run -d --rm --hostname hadoop --name hive3 -p 8088:8088/tcp
#             -p 19888:19888/tcp -p 50070:50070/tcp -p 50075:50075/tcp
#             -p 10000:10000/tcp -p 8080:8080/tcp
#             hive3:<tag_name>
#  docker exec -it hive3 /bin/bash
#
# Release notes (tag names):
#   3.1.1_0 - Binaries deployed under /opt and daemons executed as root user
#

FROM hadoop3_vanilla:latest
MAINTAINER raulmarinperez

USER root

# Download and extract the binaries under /opt
#
#   - Download Hive3 and Zeppelin binaries and deploy them under /opt
#   - Setup environment variables
#

#   Download binaries; deployment under /opt
RUN curl -s http://apache.rediris.es/hive/hive-3.1.1/apache-hive-3.1.1-bin.tar.gz | tar -xz -C /opt/
RUN curl -s http://apache.rediris.es/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz | tar -xz -C /opt/
RUN ln -s /opt/apache-hive-3.1.1-bin /opt/hive3
RUN ln -s /opt/zeppelin-0.8.1-bin-all /opt/zeppelin
RUN chown -R root:root /opt/apache-hive-3.1.1-bin/
RUN chown -R root:root /opt/zeppelin-0.8.1-bin-all/

#   Setup environment variables
ENV HIVE_HOME /opt/hive3
ENV ZEPPELIN_HOME /opt/zeppelin

# Hive3 initialization and setup:
#
#   - Initialize Hive Metastore (Derby backend)
#   - Update core-site.xml to allow impersonation & to be bound to all interfaces
#   - Add Hortonia Bank files into the image
#   - Create HDFS folders for Hive, add Hortonia Bank files and load them into Hive
#

#   Initialize Hive Metastore
RUN cd $HIVE_HOME; $HIVE_HOME/bin/schematool -dbType derby -initSchema 

#   Update core-site.xml to allow impersonation & to be bound to all interfaces
ADD core-site.xml $HADOOP_HOME/etc/hadoop

#   Add Hortonia Bank files into the image
RUN mkdir /root/hortonia
ADD hortonia/* /root/hortonia/
RUN bunzip2 /root/hortonia/*bz2

#   Create HDFS folders for Hive, add Hortonia Bank files and load them into Hive
WORKDIR /opt/hive3
RUN /etc/init.d/ssh start && \
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse && \
    $HADOOP_HOME/bin/hdfs dfs -chmod g+w /user/hive/warehouse && \
    # folder structure
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/us_customers && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/ww_customers && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/eu_countries && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/tax_2015 && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/claim_savings && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/provider_summary && \
    # data files copy
    $HADOOP_HOME/bin/hdfs dfs -put /root/hortonia/us_customers_data.csv /user/admin/hortoniabank_data/us_customers && \
    $HADOOP_HOME/bin/hdfs dfs -put /root/hortonia/ww_customers_data.csv /user/admin/hortoniabank_data/ww_customers && \
    $HADOOP_HOME/bin/hdfs dfs -put /root/hortonia/eu_countries.csv /user/admin/hortoniabank_data/eu_countries && \
    $HADOOP_HOME/bin/hdfs dfs -put /root/hortonia/tax_2015.csv /user/admin/hortoniabank_data/tax_2015 && \
    $HADOOP_HOME/bin/hdfs dfs -put /root/hortonia/claim_savings.csv /user/admin/hortoniabank_data/claim_savings && \
    $HADOOP_HOME/bin/hdfs dfs -put /root/hortonia/claims_provider_summary_data.csv /user/admin/hortoniabank_data/provider_summary && \
    # permissions set
    $HADOOP_HOME/bin/hdfs dfs -chown -R admin:hadoop /user/admin/hortoniabank_data && \
    $HADOOP_HOME/bin/hdfs dfs -chmod -R g+wX /user/admin/hortoniabank_data && \
    # Create Hive databases
    $HADOOP_HOME/sbin/start-yarn.sh && \
    $HADOOP_HOME/bin/mapred --daemon start historyserver && \
    # Databases built process without bringing hiveserver2 up.
    $HIVE_HOME/bin/beeline -u jdbc:hive2://  -f /root/hortonia/create-secgovdemo-hortoniabank-tables.ddl && \
    # Bring the pseudo-cluster down.
    $HADOOP_HOME/bin/mapred --daemon stop historyserver && \
    $HADOOP_HOME/sbin/stop-yarn.sh  && \
    # bring HDFS down
    $HADOOP_HOME/sbin/stop-dfs.sh

# Zeppelin setup:
# 
#   - Link Hive's libraries to the JDBC interpreter
#   - Add the file with the definition of all interpreters (Hive included).
#

#   Link Hive's libraries to the JDBC interpreter
RUN ln -s $HIVE_HOME/lib/hive-exec-3.1.1.jar $ZEPPELIN_HOME/interpreter/jdbc
RUN ln -s $HIVE_HOME/lib/hive-jdbc-3.1.1.jar $ZEPPELIN_HOME/interpreter/jdbc
RUN ln -s $HIVE_HOME/lib/hive-service-3.1.1.jar $ZEPPELIN_HOME/interpreter/jdbc
RUN ln -s $HIVE_HOME/lib/libthrift-0.9.3.jar $ZEPPELIN_HOME/interpreter/jdbc

#   Add the file with the definition of all interpreters (Hive included).
ADD interpreter.json $ZEPPELIN_HOME/conf

# Main script to initialize the container with Hadoop 3 services
#

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh"]

# Expose TCP ports to the outside world (in addition to what's already exposed):
#
#   - HIVE - Hive server2
#   - ZEPPELIN - Web-based notebook
#

#   HIVE - Hive server2
EXPOSE 10000
#   ZEPPELIN - Web-based notebook
EXPOSE 8080
