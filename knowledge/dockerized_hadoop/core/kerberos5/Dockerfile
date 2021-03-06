# kerberos5
#
# Description:
#   Docker image definition to run a KDC and Kerberos Admin server for the
#   QUEEN.KRB.TEST realm, so the DNS domain for the network should be
#   queen.krb.test.
#
#   KDC database master key is "MITiys4K5!", which is the example in the
#   installation guide (bad practice). 
#   Password for admin/admin@QUEEN.KRB.TEST principal is "l1k3U_more".
#
#   Watch https://youtu.be/zsRHOzlH30o to see it in action.
#
#   NOTE: It doesn't rely on external volumes, which means once the container
#         is stopped ALL DATA IS GONE. This image is for testing and training
#         purposes.
#
# Infra prerrequisites:
#   A non-default network where IP addresses can be managed (IPAM) is needed when
#   more than one container will work with this one together:
#
#     docker network create --ipam-driver default --subnet=172.28.0.0/16 krb_net
#
# Build instructions:
#   docker build -t kerberos5:<tag_name> .
#
# Container creation/execution, access to it and finalization:
#   docker run -dt --rm --name kerberos5 --hostname kerberos 
#                       --domainname queen.krb.test raulmarinperez/kerberos5
#   docker exec -it kerberos5 /bin/bash
#   docker kill kerberos5
#
#   If this container is going to be used as part of something bigger with some
#   other containers using this one as the authentication server, the following
#   will be needed:
#
#   docker network create --ipam-driver default --subnet=172.28.0.0/16 krb_net
#   docker run -dt --rm --name kerberos5 --hostname kerberos 
#              --domainname queen.krb.test --network krb_net --ip 172.28.0.2 
#              --add-host hadoop.krb.test:172.28.0.3 kerberos5:<tag_name>
#   (the other containers should be started in a similar way)
#
# Release notes (tag names):
#   stretch - Release built when base image was based on Debian 9 (Stretch)
#

FROM base
MAINTAINER raulmarinperez

USER root

# Install software and setup environment:
#
#   - Update repo and install software from the repo
#   - Replace configuration files with the custom ones
#   - Add realm initialization scripts to root's home
#

#   Update repo and install software from the repo
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y
RUN apt-get install -yq expect krb5-kdc krb5-admin-server

#   Update repo and install software from the repo
ADD krb5.conf /etc/krb5.conf
ADD kdc.conf /etc/krb5kdc
ADD kadm5.acl /etc/krb5kdc

#   Add realm initialization scripts to root's home
ADD scripts/script_create_krb5_db.exp /root
ADD scripts/script_add_admin_into_krb5_db.exp /root

# Create Kerberos database and admin/admin@QUEEN.KRB.TEST principal.
#

RUN expect -f /root/script_create_krb5_db.exp
RUN expect -f /root/script_add_admin_into_krb5_db.exp

# Main script to initialize the container and KDC and Kerberos administration 
# servers.
#

ADD bootstrap.sh /etc/bootstrap.sh
RUN chown root:root /etc/bootstrap.sh
RUN chmod 700 /etc/bootstrap.sh

ENV BOOTSTRAP /etc/bootstrap.sh
CMD ["/etc/bootstrap.sh"]

# Expose Kerberos ports to the outside world
#
#   KERBEROS - 88(tcp) and 750(udp)

EXPOSE 88 750

# Some links I found useful while building this file:
#
#   - Kerberos Protocol Tutorial: http://www.kerberos.org/software/tutorial.html
#   - Installing KDC: http://web.mit.edu/kerberos/krb5-current/doc/admin/install_kdc.html
#   - MIT Kerberos Documentation - For users: http://web.mit.edu/kerberos/krb5-current/doc/user/index.html
#   - MIT Kerberos Documentation - Application servers: http://web.mit.edu/kerberos/krb5-current/doc/admin/appl_servers.html
