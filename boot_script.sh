#!/bin/bash

# Log file path
LOGFILE="/home/sadeghesfahani/setup.log"

# Wait for network availability
while ! ping -c1 www.google.com >/dev/null 2>&1
do
    sleep 1
done

echo "Network is up." >> $LOGFILE

# Download the script
wget -O /home/sadeghesfahani/deploy.sh https://raw.githubusercontent.com/sadeghesfahani/sensor_network/main/deploy.sh
echo "Script downloaded." >> $LOGFILE

# Make the script executable
chmod +x /home/sadeghesfahani/deploy.sh

# Execute the script
/home/sadeghesfahani/deploy.sh