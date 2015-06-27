#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`

if [ $1 == "--help" ]; then
  echo "Build linux 4.1 Samus"
  echo "This script generates a patched Linux 4.1 kernel tree containing the code necessary to"
  echo "enable sound, screen and keyboard brightness on the chromebook Pixel 2."
  echo "The script also generates Debian and ArchLinux packages."
  echo "Usage: build.sh [--nopatch]"
  echo "--nopatch skips creation of patched tree allowing for incremental builds"
  exit 0
fi
if [ "$1" -ne "--nopatch" ]; then
  $DIR/patch.sh
fi
if [ $? -ne 0 ]; then
  exit 1
fi
cd $DIR/archlinux
./build.sh
if [ $? -ne 0 ]; then
  exit 1
fi
cd $DIR/debian
./build.sh
if [ $? -ne 0 ]; then
  exit 1
fi
echo
echo All done!
