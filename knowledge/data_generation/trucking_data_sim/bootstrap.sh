#!/bin/bash

RM_IMAGE_VERSION="Debian stretch"
RM_IMAGE_NAME="Trucking Data Simulator"
echo -e "\e[102mStarting $RM_IMAGE_NAME ($RM_IMAGE_VERSION) image...\e[0m"
sleep 5

# Start the simulator and send the events to the HTTP end point if provided:
#   - Start the simulator
#   - Send events if the HTTP end point is defined
#

echo -e "  \e[32m  * Starting the Trucking Data Simulator ($RM_IMAGE_VERSION, $RM_IMAGE_NAME).\e[0m"
java -cp $DATA_LOADER_HOME/stream-simulator-jar-with-dependencies.jar \
     hortonworks.hdp.refapp.trucking.simulator.SimulationRunnerApp \
     20000 \
     hortonworks.hdp.refapp.trucking.simulator.impl.domain.transport.Truck \
     hortonworks.hdp.refapp.trucking.simulator.impl.collectors.FileEventCollector \
    1 \
    $DATA_LOADER_HOME/routes/midwest/ \
    10000 \
    /tmp/truck-sensor-data/all-streams.txt \
    ALL_STREAMS > /dev/null &

# Main loop
#

if [ ! -z "$HEC_URL" ] && [ ! -z "$HEC_TOKEN" ]; then
    echo -e "  \e[32m  * Sending events to the HEC end point.\e[0m"
    /opt/Data-Loader/events_2_HEC.sh
else
    echo -e "  \e[32m  * Events are not sent outside the container, but appended to a local file.\e[0m"
    echo -e "\e[102mContainer in the main loop, enjoy the contents :)\e[0m"
    while true; do sleep 1000; done
fi

