#!/bin/bash
export PATCH=$1
if [ $# -lt 1 ]; then
  export PATCH=../generated.patch
fi
export LINUX=$2
if [ $# -lt 2 ]; then
  export LINUX=linux-head
fi

echo Patching $LINUX

rm -f $LINUX/drivers/leds/leds-chromeos-keyboard.c
rm -f $LINUX/drivers/video/backlight/chromeos_keyboard_bl.c
rm -f $LINUX/sound/soc/intel/boards/bdw-rt5677.
cd $LINUX

# Apply created patch
patch -p1 < ../generated.patch
if [ $? -ne 0 ]; then
  echo Something wrong happened...
  echo I couldn\'t patch the main tree with the created patch which means that changes upstream require an update to this script.
  exit 1
fi

# Adjust
mv sound/soc/intel/bdw-rt5677.c sound/soc/intel/boards/bdw-rt5677.c
mv sound/soc/intel/sst-debugfs.* sound/soc/intel/common
cp ../config .config

# Apply custom patch
patch -p1 < ../monkey.patch
if [ $? -ne 0 ]; then
  echo Something wrong happened...
  echo I couldn\'t patch the main tree with the custom patch which means that changes upstream require an update to this script.
  exit 1
fi

echo $LINUX now contains the patched source and a default config

