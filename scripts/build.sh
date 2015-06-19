#!/bin/bash

echo This script will clone two complete copies of the kernel source code.
echo The first copy from the official \'Linus\' tree and the second from the chromium tree.
echo This takes a while and uses a lot of disk space - you\'ve been warned.
read -p 'Are you sure? (y/n)' -n 1 -r
echo

export LINUX=linux-head
export CHROMEOS=chromiumos-chromeos-3.14
export PATCHED=v4.1-rc8
if [ $# -gt 0 ]; then
  export PATCHED=$1
fi

if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ ! -d $LINUX ]; then
    git clone https://github.com/torvalds/linux.git $LINUX
  fi
  if [ ! -d $CHROMEOS ]; then
    git clone https://chromium.googlesource.com/chromiumos/third_party/kernel $CHROMEOS
  fi
fi
if [ ! -d $LINUX ]; then
  echo $LINUX does not exist, cannot proceed.
  exit 1
fi
if [ ! -d $CHROMEOS ]; then
  echo $CHROMEOS does not exist, cannot proceed.
  exit 1
fi

echo Resetting repos
cd $LINUX
git clean -qfdx
git reset --hard $PATCHED
if [ $? -ne 0 ]; then
  exit 1
fi
cd ../$CHROMEOS
git clean -qfdx
git checkout chromeos-3.14
if [ $? -ne 0 ]; then
  exit 1
fi
cd ..

echo Creating patches
./create_patch.sh generated.patch
if [ $? -ne 0 ]; then
  exit 1
fi
./apply_patch.sh
if [ $? -ne 0 ]; then
  exit 1
fi

echo Successfully patched Linux!!
echo You may compile and install it with e.g.:
echo
echo cd linux-head
echo sh -c \'make -j4\'
echo sh -c \'sudo make install\'

