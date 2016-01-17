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
# Touchpad - seems to be using i2c dev 0 or 7
FOUND=0
DEV=0
while [ $FOUND -ne 1 ]; do
  OUT=$(echo -ne 'i\nq\n' | $PROMPT ./mxt-app -d i2c-dev:$DEV-004a 2>/dev/null)
  if [[ $OUT == *"Atmel maXTouch"* ]]; then
    FOUND=1
  else
    ((DEV++))
    if [ $DEV -gt 15 ]; then
      echo touchpad device not found - exiting
      exit 1
    fi
  fi
done
echo -ne 'r\nq\n' | $PROMPT mxt-app -d i2c-dev:$DEV-004a &>/dev/null
echo -ne 'r\nq\n' | $PROMPT mxt-app -d i2c-dev:$(expr $DEV+1)-004b &>/dev/null
echo touchpad device i2c-dev:$DEV-004a reset

