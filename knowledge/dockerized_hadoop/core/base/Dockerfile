# base
# 
# Description:
#   Docker image containing Debian 9 Stretch as base image for the rest.
#
#   NOTE: It doesn't rely on external volumes, which means once the container
#         is stopped ALL DATA IS GONE. This image is for testing and training
#         purposes.
#
# Build instructions:
#   docker build -t base:<tag_name> .
#
# Container execution and access to services:
#  docker run -d --rm --hostname base --name base base:<tag_name>
#  docker exec -it base /bin/bash
#
# Release notes (tag names):
#   stretch_0 - Debian 9 Stretch updated on July'19
#

FROM debian:stretch
MAINTAINER raulmarinperez

# Update system packages to the latest versions
#

RUN apt-get update -y
RUN apt-get upgrade -y
