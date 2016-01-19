#!/bin/bash

# Elevate privileges if necessary
PROMPT=sudo

[ "$UID" -eq 0 ] || $PROMPT cp enable-atmel.sh mxt-app /usr/local/bin

if [ ! -f /etc/systemd/system/atmel.service ];then
  $PROMPT cp enable-atmel.service /etc/systemd/system/atmel.service
  echo "atmel.service copied to /etc/systemd/system"
  $PROMPT systemctl enable atmel.service
  echo "atmel.service enabled"
else
  echo "atmel.service already configured, skipping"
fi
