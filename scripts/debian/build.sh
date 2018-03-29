#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../../build/linux-patched`
DEBIAN=`readlink -f $LINUX/../debian`

if [ ! -d $LINUX ]; then
  echo "The tree must be setup first, couldn't find it at $LINUX"
  exit 1
fi

cd $LINUX
echo `pwd`
export KDEB_CHANGELOG_DIST=vivid
export DEB_BUILD_OPTIONS=parallel=4

# Don't clean - we just compiled
cd scripts/package
#sed -i '/(MAKE) clean/ c\\#' builddeb
#sed -i '/(MAKE) clean/ c\\#' Makefile
cd ../..

make deb-pkg -j4
if [ $? -ne 0 ]; then
  echo "** Build failed, aborting"
  exit 1
fi
mkdir -p $DEBIAN
mv ../*.deb $DEBIAN
echo "Debian packages generated in $DEBIAN"
