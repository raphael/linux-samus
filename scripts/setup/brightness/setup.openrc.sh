#!/bin/bash

# Elevate privileges if necessary
PROMPT=sudo

SCRIPT=enable-brightness.sh
INIT_PATH=/etc/local.d/enable-brightness.start

if [ ! -d /etc/local.d ]; then
    $PROMPT mkdir /etc/local.d
fi
$PROMPT cp $SCRIPT $INIT_PATH
echo "$SCRIPT copied to $INIT_PATH"
$PROMPT rc-update add local default
$PROMPT rc-service local restart
