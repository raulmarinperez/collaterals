FROM hive2
MAINTAINER raulmarinperez

USER root

# Upload data files to a temporary folder and uncompress them.
#
RUN mkdir -p /tmp/data
ADD data/* /tmp/data/
ADD create-secgovdemo-hortoniabank-tables.ddl /usr/local/apache-hive-2.3.5-bin/scripts/
RUN bunzip2 /tmp/data/*bz2

# Setup the pseudo-cluster with all the hortoniabank artifacts:
#   1. Start dfs, build folder structure, upload the files into HDFS and setup permissions.
#   2. Start up YARN and the history server.
#   3. Run the DDL script to create databases, tables (external and then managed).
#   4. Bring the pseudo-cluster down in the right order.
#
RUN /etc/init.d/ssh start && \
    $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/sbin/start-dfs.sh && \
    # folder structure
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/us_customers && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/ww_customers && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/eu_countries && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/tax_2015 && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/claim_savings && \
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/admin/hortoniabank_data/provider_summary && \
    # data files copy
    $HADOOP_HOME/bin/hdfs dfs -put /tmp/data/us_customers_data.csv /user/admin/hortoniabank_data/us_customers && \
    $HADOOP_HOME/bin/hdfs dfs -put /tmp/data/ww_customers_data.csv /user/admin/hortoniabank_data/ww_customers && \
    $HADOOP_HOME/bin/hdfs dfs -put /tmp/data/eu_countries.csv /user/admin/hortoniabank_data/eu_countries && \
    $HADOOP_HOME/bin/hdfs dfs -put /tmp/data/tax_2015.csv /user/admin/hortoniabank_data/tax_2015 && \
    $HADOOP_HOME/bin/hdfs dfs -put /tmp/data/claim_savings.csv /user/admin/hortoniabank_data/claim_savings && \
    $HADOOP_HOME/bin/hdfs dfs -put /tmp/data/claims_provider_summary_data.csv /user/admin/hortoniabank_data/provider_summary && \
    # permissions set
    $HADOOP_HOME/bin/hdfs dfs -chown -R admin:hadoop /user/admin/hortoniabank_data && \
    $HADOOP_HOME/bin/hdfs dfs -chmod -R g+wX /user/admin/hortoniabank_data && \
    # Create Hive databases
    $HADOOP_HOME/sbin/start-yarn.sh && \
    $HADOOP_HOME/bin/mapred --daemon start historyserver && \
    # Databases built process without bringing hiveserver2 up.
    $HIVE_HOME/bin/beeline -u jdbc:hive2://  -f $HIVE_HOME/scripts/create-secgovdemo-hortoniabank-tables.ddl && \
    # Bring the pseudo-cluster down.
    $HADOOP_HOME/bin/mapred --daemon stop historyserver && \
    $HADOOP_HOME/sbin/stop-yarn.sh  && \
    # bring HDFS down
    $HADOOP_HOME/sbin/stop-dfs.sh

# Update core-site.xml to allow impersonation and bind the namenode to all interfaces
#
ADD core-site.xml.template $HADOOP_HOME/etc/hadoop

# Bootstrap script and expose ports are inherited from the hive2 images; nothing else added
#