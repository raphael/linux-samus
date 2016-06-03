#!/bin/bash

# Elevate privileges
PROMPT=sudo
[ "$UID" -eq 0 ] || exec $PROMPT bash "$0" "$@"

# 1. Copy firmware
if [ -d "/lib/firmware" ]; then
    cp -r ../../../firmware/* /lib/firmware
elif [ -d "/usr/lib/firmware" ]; then
    cp -r ../../../firmware/* /usr/lib/firmware
else
    echo "Could not find firmware directory; skipping firmware install."
fi

# 2. Set card order
cp modprobe.d/alsa-bdwrt5677.conf /etc/modprobe.d

# 3. Set verb
echo "Setting sound card UCM verb..."
su $SUDO_USER -c "ALSA_CONFIG_UCM=ucm/ alsaucm -c bdw-rt5677 set _verb HiFi"
if [ ! $? -eq 0 ]; then
    echo "!! Failed to set UCM verb; make sure 'alsaucm' is installed."
    exit 1
fi

# 4. Set microphone device
egrep -q '^[    ]*load-module module-alsa-source device=hw:1,1' /etc/pulse/default.pa
if [ $? -eq 0 ]; then
    sed -i '/^[     ]*load-module module-alsa-source device=hw:1,1/d' /etc/pulse/default.pa
fi
egrep -q '^[    ]*load-module module-alsa-source device=hw:1,2' /etc/pulse/default.pa
if [ $? -eq 0 ]; then
    sed -i '/^[     ]*load-module module-alsa-source device=hw:1,2/d' /etc/pulse/default.pa
fi
egrep -q '^[    ]*load-module module-alsa-source device=hw:0,1' /etc/pulse/default.pa
egrep -q '^[    ]*load-module module-alsa-source device=hw:0,2' /etc/pulse/default.pa

alreadyset=$?
if [ ! $alreadyset -eq 0 ]; then
    echo "Updating PulseAudio config with microphone hardware info..."
    cp /etc/pulse/default.pa /etc/pulse/default.pa.orig
    sed -i '/load-module module-udev-detect/ i load-module module-alsa-source device=hw:0,1' /etc/pulse/default.pa
    sed -i '/load-module module-udev-detect/ i load-module module-alsa-source device=hw:0,2' /etc/pulse/default.pa
    if [ ! $? -eq 0 ]; then
        echo "!! Failed to patch /etc/pulse/default.pa, proceeding anyway."
    else
        pulseaudio -k
        pulseaudio -D
        if [ ! $? -eq 0 ]; then
            echo "!! Failed to restart pulseaudio, the original config is available at /etc/pulse/default.pa.orig"
            exit 1
        fi
        echo "PulseAudio config successfully updated."
    fi
fi

# 5. Restore speakers.state for speakers
echo "Restoring asla config..."
alsactl restore --file alsa/speakers.state
alsactl store

# 6. Setup ACPI hooks for switching between speakers and headphones
echo "Setting up ACPI hooks..."
ACPID_DIR=/etc/acpi
if [ ! -d "$ACPID_DIR" ]; then
    echo "!! apcid is required but not installed. Please install and run this script again."
    echo "!! Sound setup completed unsuccessfully."
    exit 1
else
    cp -r actions events $ACPID_DIR/
    if [ $? -eq 0 ]; then
        echo "ACPI hooks successfully installed."
        echo -e "\e[93m!! Please remove all previously configured hooks that recognize \`jack/headphone\`.\e[0m"
    else
        echo "!! Could not copy specified directories."
        echo "!! Sound setup completed unsuccessfully."
    fi
fi

# 7. Profit
echo "Sound setup completed successfully."
exit 0
