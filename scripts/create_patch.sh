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
files[6]="include/trace/events/asoc.h"
files[7]="include/sound/soc-dapm.h"
files[8]="include/sound/rt286.h"
files[9]="include/sound/rt5677.h"
files[10]="include/sound/soc-dai.h"
files[11]="include/sound/soc-dpcm.h"
files[12]="include/sound/soc.h"
files[13]="sound/soc/codecs/rt286.c"
files[14]="sound/soc/codecs/rt286.h"
files[15]="sound/soc/codecs/rt5677-spi.c"
files[16]="sound/soc/codecs/rt5677-spi.h"
files[17]="sound/soc/codecs/rt5677.c"
files[18]="sound/soc/codecs/rt5677.h"
files[19]="sound/soc/intel/Kconfig"
files[20]="sound/soc/intel/boards/bdw-rt5677.c"
files[21]="sound/soc/intel/boards/broadwell.c"
files[22]="sound/soc/intel/common/sst-acpi.c"
files[23]="sound/soc/intel/common/sst-acpi.c"
files[24]="sound/soc/intel/common/sst-debugfs.c"
files[25]="sound/soc/intel/common/sst-debugfs.h"
files[26]="sound/soc/intel/common/sst-dsp-priv.h"
files[27]="sound/soc/intel/common/sst-dsp.c"
files[28]="sound/soc/intel/common/sst-dsp.h"
files[29]="sound/soc/intel/common/sst-firmware.c"
files[30]="sound/soc/intel/haswell/sst-haswell-dsp.c"
files[31]="sound/soc/intel/haswell/sst-haswell-ipc.c"
files[32]="sound/soc/intel/haswell/sst-haswell-ipc.h"
files[33]="sound/soc/intel/haswell/sst-haswell-pcm.c"
files[34]="sound/soc/soc-cache.c"
files[35]="sound/soc/soc-compress.c"
files[36]="sound/soc/soc-core.c"
files[37]="sound/soc/soc-dapm.c"
files[38]="sound/soc/soc-io.c"
files[39]="sound/soc/soc-jack.c"
files[40]="sound/soc/soc-pcm.c"

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

# Cleanup
rm -rf tmp_kernel_patches

echo Patch created in $TARGET

