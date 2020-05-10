# minetest_server
#
# Description:
#   Docker image definition to spin up a minetest server with some mods which
#   can be handy for testing bigdata technology.
#
# Build instructions:
#   docker build -t minetest_server:<tag_name> .
#
# Volume creation:
#   docker volume create minetest
#
# Container creation/execution:
#   docker run -dt --rm -p 30000:30000/udp -p 4711:4711/tcp
#              --name minetest --hostname minetest --domainname raulmarin.me 
#              -v minetest:/root/.minetest minetest_server
#   docker exec -it minetest /bin/bash
#   docker kill minetest
#
# Release notes (tag names):
#   0.1 - Initial release
#         (May 4th, 2020)
#
FROM alpine:3.11

USER root

# Server installation and folder structure creation:
#
#   - Install minetest server, bash and git packages
#   - Create the default Minetest home folder

RUN apk add minetest-server bash git lua5.1 lua-socket python3 && \
    mkdir -p /root/.minetest /root/minetest_blueprint/worlds/myworld \
             /root/minetest_blueprint/mods

# Create volume /root/.minetest to keep state over restarts. Main contents:
#
#   - worlds/, to store worlds (https://wiki.minetest.net/World)
#   - mods/, to store mods (https://wiki.minetest.net/Mods)
#   - games/, to store games (https://wiki.minetest.net/Games)
#   - minetest.conf, to store configuraton 
#      (https://github.com/minetest/minetest/blob/master/minetest.conf.example)
VOLUME [ "/root/.minetest" ]

# Add the following files:
#   - bootstap.sh, init script with all the logic to start the server up
#   - default/minetest.conf, initial configuration file to be used by default
#   - default/worlds/myworld/world.mt, definition for the default "myworld" world
#   - default/mods/raspberryjammod.tgz, raspberryjammod mod to use the mcpi library
ADD bootstrap.sh /etc/minetest/bootstrap.sh
ADD default/minetest.conf /etc/minetest/minetest.conf
ADD default/worlds/myworld/world.mt /root/minetest_blueprint/worlds/myworld/world.mt
ADD default/mods/raspberryjammod.tgz /root/minetest_blueprint/mods
RUN chown root:root /etc/minetest/bootstrap.sh && \
    chown root:root /etc/minetest/minetest.conf && \
    chmod 700 /etc/minetest/bootstrap.sh && \
    chmod 644 /etc/minetest/minetest.conf

# Setup some environment variables and define the entry point for the container:
#   - BOOTSTRAP, shell script which will start the minetest server
#   - MINETESTSERVER_HOME, home directory for the minetest server
#   - DEFAULTWORLD, world which will be serverd by default
ENV BOOTSTRAP /etc/minetest/bootstrap.sh
ENV MINETESTSERVER_HOME /root/.minetest
ENV DEFAULTWORLD myworld
CMD ["/etc/minetest/bootstrap.sh"]