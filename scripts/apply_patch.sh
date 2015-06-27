#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

PATCH=$1
if [ $# -lt 1 ]; then
  PATCH=$DIR/generated.patch
fi
LINUX=$2
if [ $# -lt 2 ]; then
  LINUX=`readlink -f $DIR/../build/linux-patched`
fi

echo Patching $LINUX

rm -f $LINUX/drivers/leds/leds-chromeos-keyboard.c
rm -f $LINUX/drivers/video/backlight/chromeos_keyboard_bl.c
rm -f $LINUX/sound/soc/intel/boards/bdw-rt5677.
cd $LINUX

# Apply created patch
echo -- Applying generated patch --
patch -p1 < $DIR/generated.patch
if [ $? -ne 0 ]; then
  echo Something wrong happened...
  echo I couldn\'t patch the main tree with the created patch which means that changes upstream require an update to this script.
  exit 1
fi

# Adjust
mv sound/soc/intel/bdw-rt5677.c sound/soc/intel/boards/bdw-rt5677.c
mv sound/soc/intel/sst-debugfs.* sound/soc/intel/common
ln -s $DIR/config .config

# Apply custom patches
echo -- Applying custom patch --
patch -p1 < $DIR/monkey.patch
if [ $? -ne 0 ]; then
  echo Something wrong happened...
  echo I couldn\'t patch the main tree with the custom patch which means that changes upstream require an update to this script.
  exit 1
fi

echo -- Applying HDMI hotplug patch --
patch -p1 < $DIR/hdmi_hotplug.patch
if [ $? -ne 0 ]; then
  echo Something wrong happened...
  echo I couldn\'t patch the main tree with the hdmi patch which means that changes upstream require an update to this script.
  exit 1
fi
echo
echo $LINUX now contains the patched source and a default config

