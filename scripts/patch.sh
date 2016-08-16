#!/bin/bash
#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`
TAG=v4.7

if [ $# -gt 0 ]; then
  if [ "$1" == "--help" ]; then
    echo "usage: $0 [TAG]"
    exit 0
  fi
  TAG=$1
fi

echo This script applies the patches from https://lkml.org/lkml/2016/8/14/207 to a newly checked out
echo kernel tree using the given git tag.
echo

if [ ! -d $LINUX ]; then
  echo $LINUX does not exist, cannot proceed.
  exit 1
fi

echo Resetting repo
cd $LINUX
git fetch origin
git checkout .
git clean -qfdx
git checkout master
git checkout $TAG
git pull origin master
if [ $? -ne 0 ]; then
  exit 1
fi
git checkout $TAG

echo Patching
cp $DIR/*.patch .
patch -p1 < codec.patch
patch -p1 < driver.patch

echo
echo Successfully patched Linux!!
echo You may compile and install it with e.g.:
echo
echo cd $LINUX
echo sh -c \'make -j4\'
echo sh -c \'sudo make modules_install\'
echo sh -c \'sudo make install\'
echo
echo Once installed, reboot with the new kernel and run setup/sound.sh to
echo enable sound and microphones.
echo Use the setup/brightness script to control screen brightness
echo \(setup/brightness --help for usage information\).
