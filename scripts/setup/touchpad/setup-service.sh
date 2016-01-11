#!/bin/bash
sudo cp enable-atmel.sh /usr/local/bin
sudo cp enable-atmel.service /etc/systemd/system
systemctl enable enable-atmel.service
