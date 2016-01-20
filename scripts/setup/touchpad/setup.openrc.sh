#!/bin/bash

# Elevate privileges if necessary
PROMPT=sudo

[ "$UID" -eq 0 ] || $PROMPT cp enable-atmel.sh mxt-app /usr/local/bin

SCRIPT=enable-atmel.sh
INIT_PATH=/etc/local.d/enable-atmel.start

if [ ! -d /etc/local.d ]; then
    $PROMPT mkdir /etc/local.d
fi
$PROMPT cp $SCRIPT $INIT_PATH
echo "$SCRIPT copied to $INIT_PATH"
$PROMPT rc-update add local default
$PROMPT rc-service local restart
