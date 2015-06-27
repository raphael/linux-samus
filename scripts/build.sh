#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`

echo This script builds the patch then compiles the kernel and builds the ArchLinux and Debian
echo packages. Note that creating the patch requires resetting the `linux-patched` folder thereby
echo discarding all the build artefacts. Therefore this script is *not* idempotent, each invokation
echo will cause the entire kernel to get regenerated / recompiled.
read -p 'Are you sure? (y/n)' -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo exiting...
  exit 1
fi
$DIR/patch.sh
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
