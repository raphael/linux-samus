#!/bin/bash

if [ -d /etc/X11/xorg.conf.d ]; then
  sudo cp xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d
elif [ -d /usr/share/X11/xorg.conf.d ]; then
  sudo cp xorg.conf.d/20-intel.conf /usr/share/X11/xorg.conf.d
else
  echo "failed to find xorg.conf.d directory"
  exit 1
fi
echo DONE
echo Make sure you have the intel drivers installed!
echo On Archlinux: package xf86-video-intel
