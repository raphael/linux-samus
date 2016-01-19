#!/bin/bash

# Elevate privileges if necessary
PROMPT=sudo

[ "$UID" -eq 0 ] || $PROMPT cp brightness keyboard_led enable-brightness.sh /usr/local/bin

if [ ! -f /etc/systemd/system/brightness.service ];then
  $PROMPT cp enable-brightness.service /etc/systemd/system/brightness.service
  echo "brightness.service copied to /etc/systemd/system"
  $PROMPT systemctl enable brightness.service
  echo "brightness.service enabled"
else
  echo "brightness.service already configured, skipping"
fi
