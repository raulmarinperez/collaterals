#!/bin/bash

RM_IMAGE_VERSION=stretch
RM_IMAGE_NAME="Kerberos 5"
echo -e "\e[102mStarting $RM_IMAGE_NAME ($RM_IMAGE_VERSION) image...\e[0m"
sleep 5

# Starting services:
#   - Starting KDC server
#   - Starting Kerberos Admin server
#

echo -e "  \e[32m  * Starting KDC server.\e[0m"
krb5kdc
echo -e "  \e[32m  * Starting Kerberos Admin server.\e[0m"
kadmind

# Main loop
#

echo -e "\e[102mContainer in the main loop, enjoy the contents :)\e[0m"
while true; do sleep 1000; done
