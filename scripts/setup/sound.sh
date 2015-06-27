#!/bin/bash

# 1. Set verb
echo "Setting sound card UCM verb"
ALSA_CONFIG_UCM=ucm/ alsaucm -c bdw-rt5677 set _verb HiFi
if [ ! $? -eq 0 ]; then
  echo "!!Failed to set UCM verb, make sure 'alsaucm' is installed"
  exit 1
fi

# 2. Set microphone device
egrep -q '^[ 	]*load-module module-alsa-source device=hw:1,1' /etc/pulse/default.pa
egrep -q '^[ 	]*load-module module-alsa-source device=hw:1,2' /etc/pulse/default.pa
alreadyset=$?
if [ ! $alreadyset -eq 0 ]; then
  echo "Updating PulseAudio config with microphone hardware info"
  sudo cp /etc/pulse/default.pa /etc/pulse/default.pa.orig
  sudo sed -i '/load-module module-udev-detect/ i load-module module-alsa-source device=hw:1,1' /etc/pulse/default.pa
  sudo sed -i '/load-module module-udev-detect/ i load-module module-alsa-source device=hw:1,2' /etc/pulse/default.pa
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

# 3. Copy vda firmware
if [ -d "/lib/firmware" ]; then
  sudo cp ../../firmware/* /lib/firmware
elif [ -d "/usr/lib/firmware" ]; then
  sudo cp ../../firmware/* /usr/lib/firmware
else
  echo "Could not find firmware directory, skipping firmware install"
fi

# 4. Set alsa mic level
echo "Unmuting mic"
amixer -c1 set Mic 0DB
if [ ! $? -eq 0 ]; then
  echo "!!Failed to unmute mic, check that 'amixer' is installed"
  exit 1
fi

# 4. Profit
echo "Sound setup completed successfully."
