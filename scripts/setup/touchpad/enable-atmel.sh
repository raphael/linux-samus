#!/bin/bash

sudo modprobe i2c-dev
echo -ne 'r\nq\n' | sudo ./mxt-app -d i2c-dev:7-004a
