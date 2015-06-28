#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../../build/linux-patched`
DEBIAN=`readlink -f $LINUX/../debian`

if [ ! -d $LINUX ]; then
  echo "The patched tree must be generated first, couldn't find it at $LINUX"
  echo "run ../build.sh to generate it"
  exit 1
fi

cd $LINUX
echo `pwd`
export KDEB_CHANGELOG_DIST=vivid
make deb-pkg
if [ $? -ne 0 ]; then
  echo "** Build failed, aborting"
  exit 1
fi
mkdir -p $DEBIAN
mv ../*.deb $DEBIAN
echo "Debian packages generated in $DEBIAN"
