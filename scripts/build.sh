#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`

if [[ $1 == "--help" ]]; then
  echo "Build linux 4.5 Samus"
  echo "This script generates a patched Linux 4.5 kernel tree containing the code necessary to"
  echo "enable sound, screen and keyboard brightness on the chromebook Pixel 2."
  echo "The script also generates Debian and ArchLinux packages."
  echo "Usage: build.sh [--nopatch|branch tag]"
  echo "--nopatch skips creation of patched tree allowing for incremental builds"
  echo "branch is git branch, e.g. linux-4.5.y"
  echo "tag is git tag, e.g. v4.5.1"
  exit 0
fi
export branch="$1"
if [[ "$branch" == "" ]]; then
  export branch="linux-4.5.y"
fi
export tag="$2"
if [[ "$tag" == "" ]]; then
  export tag="v4.5.1"
fi
if [[ "$1" != "--nopatch" ]]; then
  $DIR/patch.sh $branch $tag
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
