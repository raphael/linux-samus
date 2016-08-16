#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`

if [[ $1 == "--help" ]]; then
  echo "Build linux 4.7 Samus"
  echo "This script generates a patched Linux 4.7 kernel tree containing the code necessary to"
  echo "enable sound on the chromebook Pixel 2."
  echo "The patches are from https://lkml.org/lkml/2016/8/14/207"
  echo "The script also generates Debian and ArchLinux packages."
  exit 0
fi
export tag="$1"
if [[ "$tag" == "" ]]; then
  export tag="v4.7"
fi
$DIR/patch.sh $tag
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
