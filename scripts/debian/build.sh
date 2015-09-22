#!/bin/bash

export FLAVOUR=samus
export DEBEMAIL="simon.raphael@gmail.com"
export DEBFULLNAME="Raphael Simon"
export KDEB_CHANGELOG_DIST=vivid

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LINUX=`readlink -f $DIR/../../build/linux-patched`
DEBIANPATH=`readlink -f $LINUX/../debian`

if [ ! -d $LINUX ]; then
  echo "The patched tree must be generated first, couldn't find it at $LINUX"
  echo "run ../build.sh to generate it"
  exit 1
fi

rm -rf $LINUX/debian
rm -rf $LINUX/debian.master
cp -r debian $LINUX
cp -r debian.master $LINUX
cd $LINUX

# Now build source package
#export KERNELVERSION=$(make EXTRAVERSION='' kernelversion) 
#rm -f debian/changelog
#dch --create --changelog debian/changelog --package linux-$FLAVOUR -v ${KERNELVERSION}
dch -r ""
VERSION="`sed -n '1 s/^.*(\(.*\)).*/\1/p' debian/changelog`"
PPA_FILE="`make --no-print-directory -f debian/rules print-ppa-file-name`"
KEYID="`gpg --list-keys ${DEBEMAIL} | sed -n 's,^pub.*/\([^ ]*\).*,\1,p'`"
# with -nc size is 315232140
dpkg-buildpackage -j4 -S -sa -k${KEYID} -rfakeroot -I.git -I.gitignore -i'\.git.*'
if [ $? -ne 0 ]; then
  echo "** Build failed, aborting"
  exit 1
fi
mkdir -p $DEBIANPATH
rm -rf $DEBIANPATH/*
rm ../*.deb
mv ../*.changes $DEBIANPATH
mv ../*.dsc $DEBIANPATH
mv ../*.tar.gz $DEBIANPATH
cd $DEBIANPATH
dput ppa:simon-raphael/linux-samus ./*.changes
