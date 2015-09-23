#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../../build/linux-patched`
LINUXSRC=`readlink -f $DIR/../../build/linux`
DEBIANPATH=`readlink -f $LINUX/../debian`

export FLAVOUR=samus
export DEBEMAIL="simon.raphael@gmail.com"
export DEBFULLNAME="Raphael Simon"
cd $LINUX
export KERNELRELEASE=$(make kernelrelease)
cd $DIR
export DEBIAN_REVISION_MANDATORY=${KERNELRELEASE}.samus
export CONCURRENCY_LEVEL=4
echo Building revision $DEBIAN_REVISION_MANDATORY

if [ "$1" == "--help" ]; then
  echo Usage: ./build.sh [--nocopy] [--nochange]
  echo --nocopy: do not create $LINUX directory
  echo --nochange: do not edit package changelog
fi

if [ ! -d $LINUX ]; then
  echo "The patched tree must be generated first, couldn't find it at $LINUX"
  echo "run ../build.sh to generate it"
  exit 1
fi

# Prepare source
if [ ! "$1" == "--nocopy" ] && [ ! "$2" == "--nocopy" ]; then
  echo Setting up sources
  rm -rf $LINUXSRC
  cp -r $LINUX $LINUXSRC
  cd $LINUXSRC
  rm -rf .git
  make clean
  rm .config
  ln -s ../../scripts/config .config
fi

# Create debian directory if needed
if [ ! -d ./debian ]; then
  echo Building "debian" files
  make-kpkg debian
  if [ $? -ne 0 ]; then
    echo "** debian files failed to build, aborting"
  fi
  sed -i '/^Maintainer: /c\Maintainer: Raphael Simon <simon.raphael@gmail.com>' ./debian/control
else
  echo "Found pre-existing debian files, using them"
fi

# Update changelog
if [ ! "$1" == "--nochange" ] && [ ! "$2" == "--nochange" ]; then
  dch --changelog debian/changelog --distribution vivid
fi

# Now build source package
KEYID="`gpg --list-keys ${DEBEMAIL} | sed -n 's,^pub.*/\([^ ]*\).*,\1,p'`"
echo Building source package
dpkg-buildpackage -j4 -S -nc -sa -k${KEYID} -rfakeroot -I.git -I.gitignore -i'\.git.*'
if [ $? -ne 0 ]; then
  echo "** Debian source package build failed, aborting"
  exit 1
fi
mkdir -p $DEBIANPATH
rm -rf $DEBIANPATH/*
mv ../*.changes $DEBIANPATH
mv ../*.dsc $DEBIANPATH
mv ../*.tar.gz $DEBIANPATH

echo Debian source package successfully built at $DEBIANPATH
