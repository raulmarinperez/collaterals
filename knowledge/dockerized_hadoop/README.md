## Dockerized Hadoop
Docker image definition to let people play around with Hadoop and its ecosystem in a small deployment. No enterprise class configuration such as security, multitenancy, ... are considered nor setup.

This is what you'll find in this folder:

 - **[base](base).-** simple base image; nothing fancy but it will allow more flexibility to add new features in the future.
 - **[hadoop3.2_vanilla](hadoop3.2_vanilla).-** single node Hadoop "cluster" with HDFS (Data Node, Name Node and Secondary Node), YARN and MapReduce framework. It exposes TCP ports 22 (SSH), 8088 (Resource Manager), 19888 (MR JobHistory Server), 50070 (Name Node) and 50075 (Data Node).
 - **[hive2](hive2).-** based on the hadoop3.2_vanilla image, it adds Hive2 and Zeppelin; a hive interpreter is added to make easier the interaction with Hive. In addition to the ports already exposed by the base image, it exposes TCP ports 10000 (Thrift server - JDBC) and 8080 (Zeppelin).
 - **[hive2_hortoniabank](hive2_hortoniabank).-** based on the hive2 image, it adds Hive artifacts from the Hortonia Bank demo available in [Ali Bajwa's github](https://github.com/abajwa-hw/masterclass/tree/master/ranger-atlas); to know some more about this demo, visit [HDP Security/Governance/GDPR Demo Kit (updated for HDP 3.1)](https://community.hortonworks.com/articles/151939/hdp-securitygovernance-demo-kit.html) and check what can be done from Zeppelin (remember that only Hive artifacts are available in the image, no security nor other components are available).
 
Raul
