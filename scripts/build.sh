#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`

if [[ $1 == "--help" ]]; then
  echo "Build linux 4.9 Samus"
  echo "This script generates Debian and ArchLinux packages."
  exit 0
fi

export TAG="$1"
if [[ "$TAG" == "" ]]; then
  echo "Usage: build.sh TAG"
fi

if [ ! -d $LINUX ]; then
  echo $LINUX does not exist, cannot proceed.
  exit 1
fi

echo Resetting repo
cd $LINUX
git fetch linus
git checkout .
git checkout master
git checkout $TAG
git pull linus $TAG
if [ $? -ne 0 ]; then
  exit 1
fi
git checkout $TAG

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
