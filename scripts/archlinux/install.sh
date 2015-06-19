#!/bin/bash

# 1. Install new kernel packages
sudo pacman -U --noconfirm linux-*.xz
if [ $? -ne 0 ]; then
  exit 1
fi

# 2. Update grub
if [ -e /boot/grub/grub.cfg ]; then
  sudo sh -c 'grub-mkconfig > /boot/grub/grub.cfg'
  sudo grub-install /dev/sda
  if [ $? -ne 0 ]; then
    exit 1
  fi
  echo GRUB successfully updated
fi

# 3. Profit
echo linux-samus-4 packages successfully installed
