#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`

if [[ $1 == "--help" ]]; then
  echo "Build linux 4.1 Samus"
  echo "This script generates a patched Linux 4.1 kernel tree containing the code necessary to"
  echo "enable sound, screen and keyboard brightness on the chromebook Pixel 2."
  echo "The script also generates Debian and ArchLinux packages."
  echo "Usage: build.sh [--nopatch|repo branch tag]"
  echo "--nopatch skips creation of patched tree allowing for incremental builds"
  echo "repo is \"linux\" or \"linux-stable\""
  echo "branch is git branch, e.g. v4.2"
  echo "tag is git tag, e.g. v4.2.1"
  exit 0
fi
export repo="$1"
if [[ "$repo" == "" ]]; then
  export repo="linux-stable"
fi
export branch="$2"
if [[ "$branch" == "" ]]; then
  export branch="v4.2"
fi
export tag="$3"
if [[ "$tag" == "" ]]; then
  export tag="v4.2"
fi
if [[ "$1" != "--nopatch" ]]; then
  $DIR/patch.sh $repo $branch $tag
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
