#!/bin/bash

# Log file path
LOGFILE="/home/sadeghesfahani/setup.log"

# Name of your network interface, usually wlan0 for WiFi on a Raspberry Pi
INTERFACE=wlan0


# Remove init from cmdline.txt
# Test IP; you can use any IP, but the Google DNS is a common choice
TESTIP=8.8.8.8

# Check network connection and reconnect if necessary
if ! ifconfig $INTERFACE | grep -q "inet addr"; then
    echo "$(date) Network seems down, trying to reconnect..." >> $LOGFILE

    # Force wlan0 up (just in case)
    sudo ifconfig $INTERFACE up

    # Reconnect to the network
    sudo wpa_cli -i $INTERFACE reconfigure

    # Wait a bit and then check again
    sleep 10

    if ! ping -c2 $TESTIP > /dev/null; then
        echo "$(date) Network is still down." >> $LOGFILE
    else
        echo "$(date) Network connection has been restored." >> $LOGFILE
    fi
else
    echo "$(date) Network is up." >> $LOGFILE
fi

# Move the boot_script.sh to /home/pi
mv /boot/boot_script.sh /home/sadeghesfahani/boot_script.sh
chmod +x /home/sadeghesfahani/boot_script.sh

# Create a systemd service file
cat > /etc/systemd/system/boot_script.service <<EOF
[Unit]
Description=Boot Script Service
After=network.target

[Service]
ExecStart=/home/sadeghesfahani/boot_script.sh
User=pi

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd manager configuration
systemctl daemon-reload

# Enable boot_script service
systemctl enable boot_script.service

# Remove init from cmdline.txt
sed -i 's| init=/bin/bash /boot/setup.sh||' /boot/cmdline.txt