#!/bin/bash

# This script resets the Atmel maXTouch chips that control the touchscreen and
# touchpad input devices.

# It is recommended for this script to be run by the init system on boot and
# after resuming from suspend.

# Note the use of "mxt-app" which would have to be available to the init system.

# Elevate privileges if necessary
PROMPT=sudo
[ "$UID" -eq 0 ] || exec $PROMPT $SHELL "$0" "$@"

# Load `i2c-dev` module to access I2C devices through /dev
$PROMPT modprobe i2c-dev &>/dev/null

# Reset controllers
echo -ne 'r\nq\n' | $PROMPT ./mxt-app -d i2c-dev:{7,8}-004a &>/dev/null
