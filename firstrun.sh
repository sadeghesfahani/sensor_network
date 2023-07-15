#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_hostname mita
else
   echo mita >/etc/hostname
   sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\tmita/g" /etc/hosts
fi
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh
else
   systemctl enable ssh
fi
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'sadeghesfahani' '$5$w.PVvMd2V5$s0Wi6s1rWwEnIoJJlpRutTToxbwr0tnA7hS7WPGKrK0'
else
   echo "$FIRSTUSER:"'$5$w.PVvMd2V5$s0Wi6s1rWwEnIoJJlpRutTToxbwr0tnA7hS7WPGKrK0' | chpasswd -e
   if [ "$FIRSTUSER" != "sadeghesfahani" ]; then
      usermod -l "sadeghesfahani" "$FIRSTUSER"
      usermod -m -d "/home/sadeghesfahani" "sadeghesfahani"
      groupmod -n "sadeghesfahani" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=sadeghesfahani/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/sadeghesfahani/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /sadeghesfahani /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_keymap 'us'
   /usr/lib/raspberrypi-sys-mods/imager_custom set_timezone 'Asia/Tehran'
else
   rm -f /etc/localtime
   echo "Asia/Tehran" >/etc/timezone
   dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
   dpkg-reconfigure -f noninteractive keyboard-configuration
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
User=sadeghesfahani

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd manager configuration
systemctl daemon-reload

# Enable boot_script service
systemctl enable boot_script.service


rm -f /boot/firstrun.sh




sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
