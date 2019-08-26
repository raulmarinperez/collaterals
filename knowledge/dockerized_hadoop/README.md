# Dockerized Hadoop environments
This folder contains different dockerized Hadoop pseudo cluster definitions providing the foundations for different scenarios. 

Dockerfiles are self-descriptive and very verbose in order to help you understanding how the image is built and what's available for you afterwards. However, the following bullet points provide you with an overview of the images to make it even easier:

* **core.-** not related directly to Hadoop itself, but it contains Docker images definitions to build complementary services to Hadoop pseudo cluster:
  * **base.-** Docker image which is the base of the rest of the Docker images considered here. It's based on Debian 9 (stretch) and, at built time, it only updates the repo and the installed packages.

    The idea behind this image is to bring a common ground for the other images; in the future it might contain new content.

  * **kerberos5.-** a MIT Kerberos 5 image to be used in kerberized environments; it's provides the starting point for those images who build kerberized services, as it only provides:

    * *KDC and Kerberos Admin services* backing up the Kerberos database for the realm **QUEEN.KRB.TEST**.
    * the **admin/admin@QUEEN.KRB.TEST** principal for administration purposes.

  It exposes TCP port 88 and UDP port 750.

* **hadoop.-** different Docker images with Hadoop as one of the services offered, if not the only one. The following images are available:

  * **hadoop3_vanilla.-** it contains Apache Hadoop 3 with default setup and services, and not security enabled. First image added relied on Hadoop 3.2, but in future releases newer versions might be added.

    It packages a pseudo-cluster/single node Hadoop deployment with HDFS (Data Node, Name Node and Secondary Node), YARN and MapReduce framework. It exposes TCP ports 8088 (Resource Manager), 19888 (MR JobHistory Server), 50070 (Name Node) and 50075 (Data Node).

    Handy image to play around with HDFS, YARN and MAPREDUCE.

  * **hadoop3_vanilla_krb.-** Kerberos authentication added to the *hadoop3_vanilla* image, no autherization setup though. Most of the setup has been done with tips from the [Hadoop in Secure Mode](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/SecureMode.html) official guide.

  * **hive2.-** built on top of the *hadoop3_vanilla* image, it adds Hive 2 with no security enabled. Recommended image for those who want to give Hive a try and it doesn't have a cluster available to do so. First image release included Hive 2.3.6, but newer versions might come in future image releases.

    In order to make the image more productive, I've added Zeppelin (with a custom Hive interpreter) and the HortoniaBank Hive artifacts obtained from [Ali Bajwa's repo](https://github.com/abajwa-hw/masterclass/tree/master/ranger-atlas).

    In addition to the ports already exposed by the base image, it exposes TCP ports 10000 (Thrift server - JDBC) and 8080 (Zeppelin).

  * **hive3.-** built on top of the *hadoop3_vanilla* image, it adds Hive 3 with no security enabled. Recommended image for those who want to give Hive a try and it doesn't have a cluster available to do so. First image release included Hive 3.1.1, but newer versions might come in future image releases.

    In order to make the image more productive, I've added Zeppelin (with a custom Hive interpreter) and the HortoniaBank Hive artifacts obtained from [Ali Bajwa's repo](https://github.com/abajwa-hw/masterclass/tree/master/ranger-atlas).

    In addition to the ports already exposed by the base image, it exposes TCP ports 10000 (Thrift server - JDBC) and 8080 (Zeppelin).

  * **hive3_krb.-** built on top of the *core.kerberos5* and *hive3* images, it brings a Hive 3 kerberized instance with the HortoniaBank Hive artifacts on it.

    First approach was to keep both images independently and bring them up together with docker-compose but, as this is just for training and testing purposes, I decided to keep it this simple.

    It exposes all the ports exposed by the images this one relies on.

  * **nifi_hadoop.-** it contains files to bring a Hadoop 3 pseudo cluster and a NiFi instance up. To do so, it includes a docker-compose.yml file to create *two containers* based on the *hadoop3_vanilla:latest* and *apache/nifi:latest* Docker images.

    It maps TCP ports 8088 (Resource Manager), 19888 (MR JobHistory Server), 50070 (Name Node) and 50075 (Data Node) from Hadoop, and TCP port 9090 (NiFi web UI), to the same local ports in the host running the image.

    Additionally, it adds the files needed to connect the NiFi instances to the Hadoop pseudo cluster (*core-site.xml* and *hdfs-site.xml*) plus a sample flow to interact with a Telegram bot and ingest messages from group chats.

    The [NiFi Lab Dockerized version](https://www.youtube.com/watch?v=-qacDryaa2A&feature=youtu.be) video presents how to configure the aforementioned scenario.
