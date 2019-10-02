#!/bin/bash

SENSOR_DATA_FILE=/tmp/truck-sensor-data/all-streams.txt

# 1. Wait for the file with sensor data up until exist
echo -e "  \e[32m     - Waiting for the file with sensor data to be ready.\e[0m"
while [ ! -f $SENSOR_DATA_FILE ]
do
  sleep 2
done

# 2. Tail the file with sensor data and send it to the HEC end point
echo -e "\e[102mContainer in the main loop, enjoy the contents :)\e[0m"
tail -n 3 -f $SENSOR_DATA_FILE | grep --line-buffered '.*' | while read LINE0
do
  curl -k $HEC_URL/services/collector/raw -H "Authorization: Splunk ${HEC_TOKEN}" \
       -d "$LINE0" 2>&1 /dev/null
done