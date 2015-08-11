#!/bin/bash

# 1. Copy firmware
if [ -d "/lib/firmware" ]; then
  sudo cp ../../firmware/* /lib/firmware
elif [ -d "/usr/lib/firmware" ]; then
  sudo cp ../../firmware/* /usr/lib/firmware
else
  echo "Could not find firmware directory, skipping firmware install"
fi

# 2. Set card order
sudo cp modprobe.d/alsa-bdwrt5677.conf /etc/modprobe.d

# 3. Set verb
echo "Setting sound card UCM verb"
ALSA_CONFIG_UCM=ucm/ alsaucm -c bdw-rt5677 set _verb HiFi
if [ ! $? -eq 0 ]; then
  echo "!!Failed to set UCM verb, make sure 'alsaucm' is installed"
  exit 1
fi

# 4. Set microphone device
egrep -q '^[ 	]*load-module module-alsa-source device=hw:1,1' /etc/pulse/default.pa
if [ $? -eq 0 ]; then
	sudo sed -i '/^[ 	]*load-module module-alsa-source device=hw:1,1/d' /etc/pulse/default.pa
fi
egrep -q '^[ 	]*load-module module-alsa-source device=hw:1,2' /etc/pulse/default.pa
if [ $? -eq 0 ]; then
	sudo sed -i '/^[ 	]*load-module module-alsa-source device=hw:1,2/d' /etc/pulse/default.pa
fi
egrep -q '^[ 	]*load-module module-alsa-source device=hw:0,1' /etc/pulse/default.pa
egrep -q '^[ 	]*load-module module-alsa-source device=hw:0,2' /etc/pulse/default.pa
alreadyset=$?
if [ ! $alreadyset -eq 0 ]; then
  echo "Updating PulseAudio config with microphone hardware info"
  sudo cp /etc/pulse/default.pa /etc/pulse/default.pa.orig
  sudo sed -i '/load-module module-udev-detect/ i load-module module-alsa-source device=hw:0,1' /etc/pulse/default.pa
  sudo sed -i '/load-module module-udev-detect/ i load-module module-alsa-source device=hw:0,2' /etc/pulse/default.pa
  if [ ! $? -eq 0 ]; then
    echo "!!Failed to patch /etc/pulse/default.pa, proceeding anyway."
  else
    pulseaudio -k
    pulseaudio -D
    if [ ! $? -eq 0 ]; then
      echo "!!Failed to restart pulseaudio, the original config is available at /etc/pulse/default.pa.orig"
      exit 1
    fi
    echo "PulseAudio config successfully updated"
  fi
fi

# 5. Restore asound.state
echo "Restoring asla config"
sudo alsactl restore --file alsa/asound.state
sudo alsactl store

# 6. Profit
echo "Sound setup completed successfully."
