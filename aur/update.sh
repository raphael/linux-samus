#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
REPO=$DIR/linux-samus4
if [ ! -d $REPO ]; then
  git clone ssh://aur@aur4.archlinux.org/linux-samus4 $REPO
  if [ $? -ne 0 ]; then
    echo Failed to clone linux-samus4
    exit 1
  fi
fi
cd $DIR

files[0]="config"
files[1]="linux.install"
files[2]="linux.preset"
files[3]="PKGBUILD"

for f in "${files[@]}"; do
  cp -L $DIR/$f $REPO
done
cd $REPO
mksrcinfo
if [ $? -ne 0 ]; then
  echo Failed to run mksrcinfo
  exit 1
fi
head -n -3 PKGBUILD > PKGBUILD.new && mv PKGBUILD.new PKGBUILD
makepkg -g >> PKGBUILD
if [ $? -ne 0 ]; then
  echo Failed to update checksums
  exit 1
fi
echo $REPO updated.
