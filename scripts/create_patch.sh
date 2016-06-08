#!/bin/bash

LINUX=linux-patched
CHROMEOS=chromiumos-chromeos-3.14
TARGET=$1
if [ $# -eq 0 ]; then
  TARGET=generated.patch
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TARGET=$DIR/$TARGET

echo This script creates a patch file from the current content of the $LINUX and $CHROMEOS repos.
echo Creating patches
files[0]="drivers/leds/Kconfig"
files[1]="drivers/leds/leds-chromeos-keyboard.c"
files[2]="drivers/leds/Makefile"
files[3]="drivers/video/backlight/chromeos_keyboard_bl.c"
files[4]="drivers/video/backlight/Kconfig"
files[5]="drivers/video/backlight/Makefile"

cd $DIR/../build
rm -rf tmp_kernel_patches
mkdir tmp_kernel_patches
for f in "${files[@]}"; do
  export cf=`echo $f | sed -e "s/\/common//" | sed -e "s/\/boards//" | sed -e "s/\/haswell//"`
  export name=`echo $f | sed -e "s/\//_/g"`
  echo "diff -Naur $LINUX/$f $CHROMEOS/$cf" > tmp_kernel_patches/$name.patch
  diff -Naur $LINUX/$f $CHROMEOS/$cf >> tmp_kernel_patches/$name.patch
done

# Create one big patch
cat tmp_kernel_patches/*.patch > $TARGET
cat $DIR/haswell-Makefile.patch >> $TARGET
cat $DIR/bdw-rt5677-Kconfig.patch >> $TARGET

# Cleanup
rm -rf tmp_kernel_patches

echo Patch created in $TARGET

