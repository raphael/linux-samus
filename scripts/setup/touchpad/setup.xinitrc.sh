#!/bin/bash

# Elevate privileges if necessary
PROMPT=sudo
[ "$UID" -eq 0 ] || $PROMPT cp enable-atmel.sh mxt-app /usr/local/bin
egrep -q 'enable-atmel.sh' ~/.xinitrc
if [ $? -ne 0 ];then
  echo "enable-atmel.sh" >> ~/.xinitrc
  echo "setup xinitrc to run enable-atmel.sh"
else
  echo "xinitrc already configured, skipping"
fi
