#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../build/linux-patched`
CHROMEOS=`readlink -f $DIR/../build/chromiumos-chromeos-3.14`
ORIGIN=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
BRANCH=linux-4.5.y
TAG=v4.5.1

if [ $# -gt 0 ]; then
  if [ "$1" == "--help" ]; then
    echo "usage: $0 [BRANCH] [TAG]"
    exit 0
  fi
fi

if [ $# -gt 1 ]; then
  if [ "$2" == "--help" ]; then
    echo "usage: $0 [BRANCH] [TAG]"
    exit 0
  fi
  BRANCH=$1
fi

if [ $# -gt 2 ]; then
  if [ "$3" == "--help" ]; then
    echo "usage: $0 [BRANCH] [TAG]"
    exit 0
  fi
  TAG=$2
fi

echo This script will clone two complete copies of the kernel source code.
echo The first copy from the official \'Linus\' tree and the second from the chromium tree.
echo This takes a while and uses a lot of disk space - you\'ve been warned.
read -p 'Are you sure? (y/n)' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ ! -d $LINUX ]; then
    git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git $LINUX
  fi
  if [ ! -d $CHROMEOS ]; then
    git clone https://chromium.googlesource.com/chromiumos/third_party/kernel $CHROMEOS
  fi
fi
if [ ! -d $LINUX ]; then
  echo $LINUX does not exist, cannot proceed.
  exit 1
fi
if [ ! -d $CHROMEOS ]; then
  echo $CHROMEOS does not exist, cannot proceed.
  exit 1
fi

echo Resetting repos
cd $LINUX
git checkout .
git clean -qfdx
git checkout $BRANCH
git checkout $TAG
cd $CHROMEOS
git clean -qfdx
git checkout chromeos-3.14
if [ $? -ne 0 ]; then
  exit 1
fi
cd $DIR

echo Creating patches
./create_patch.sh generated.patch
if [ $? -ne 0 ]; then
  exit 1
fi
./apply_patch.sh
if [ $? -ne 0 ]; then
  exit 1
fi
cp bdw-rt5677.c $LINUX/sound/soc/intel/boards
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
