# trucking_data_sim
#
# Description:
#   Docker image definition containing the Trucking Data Simulator publicly
#   available in George Vetticaden's github repository:
#
#     https://github.com/georgevetticaden/sam-trucking-data-utils
#
#   When a container is built and is running, it generates and add events into
#   a file and, if properly setup, those events are sent out of the container.
#
# Environment variables at run time:
#   HEC_URL - Splunk HEC URL; it'll be used to send raw events 
#             (HEC_URL/services/collector/raw)
#   HEC_TOKEN - active Splunk HEC token to leave events in Splunk
#
# Build instructions:
#   docker build -t trucking_data_sim:<tag_name> .
#
# Container creation/execution(Splunk HEC example), access to it and finalization:
#   docker run -dt --rm -e HEC_URL='http://splunk_host:8088' -e HEC_TOKEN='hec token'
#              --name trucking --hostname trucking --domainname datasim.raulmarin.me 
#              --network datasim_net
#              raulmarinperez/trucking_data_sim
#   docker exec -it trucking /bin/bash
#   docker kill trucking
#
#   If this container is going to be used as part of something bigger with some
#   other containers using this one as the authentication server, the following
#   will be needed:
#
#   docker network create --ipam-driver default --subnet=172.28.0.0/16 datasim_net
#   docker run -dt --rm --name trucking --hostname trucking 
#              --domainname datasim.raulmarin.me --network datasim_net
#              trucking_data_sim:<tag_name>
#   (the other containers should be started in a similar way)
#
# Release notes (tag names):
#   0.1 - Initial release
#         (Oct 2nd, 2019)
#

FROM debian:stretch
MAINTAINER raulmarinperez

USER root

# Install software and setup environment:
#
#   - Update repo and install software from the repo
#

#   Update repo and install software from the repo
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y && \
    apt-get install -yq openjdk-8-jdk-headless unzip curl

# Add the simulator into /opt
#
#   - Copy the zip to the /opt
#   - Unzip the binaries, scripts and routes
#   - Remove the zip file
WORKDIR /opt
ADD Data-Loader.zip /opt/Data-Loader.zip
RUN unzip /opt/Data-Loader.zip
WORKDIR /opt/Data-Loader
ADD events_2_HEC.sh /opt/Data-Loader/events_2_HEC.sh
RUN tar zxf /opt/Data-Loader/routes.tar.gz && \
    rm /opt/Data-Loader.zip /opt/Data-Loader/routes.tar.gz && \
    chown root:root /opt/Data-Loader/events_2_HEC.sh && \
    chmod 755 /opt/Data-Loader/events_2_HEC.sh

# Add the bootstrap file and set env variables.
ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh && \
    chmod 700 /etc/bootstrap.sh

ENV DATA_LOADER_HOME /opt/Data-Loader
ENV BOOTSTRAP /etc/bootstrap.sh
CMD ["/etc/bootstrap.sh"]

# Some links I found useful while building this file:
#
#   - Trucking Data Simulator: https://github.com/georgevetticaden/sam-trucking-data-utils
#   - Set up and use HTTP Event Collector in Splunk Web: https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector
#   - HTTP Event Collector Examples: https://docs.splunk.com/Documentation/Splunk/7.3.1/Data/HECExamples