#!/bin/bash

# Exit on error
set -e

ROOT=$( git rev-parse --show-toplevel )
KERNELVER=$1
PKGVER=$( sed -n 's/pkgver=\(.*\)/\1/p' $ROOT/aur/PKGBUILD )
PKGREL=$( sed -n 's/pkgrel=\(.*\)/\1/p' $ROOT/aur/PKGBUILD )

if [[ $ROOT == "" ]]; then
    echo "failed to retrieve git project root - giving up"
    exit 1
fi
if [[ $KERNELVER == "" ]]; then
    echo "Usage: release KERNEL_VERSION"
    echo "   Example: release v4.11.8"
    exit 1
fi
if [[ $PKGVER == "" ]]; then
    echo "couldn't retrieve PKGVER - giving up"
    exit 1
fi
if [[ $PKGREL == "" ]]; then
    echo "couldn't retrieve PKGREL - giving up"
    exit 1
fi
NEWPKGREL=$(($PKGREL+1))

echo ROOT:               $ROOT
echo PKGVER \(current\): $PKGVER
echo PKGREL \(current\): $PKGREL
echo KERNEL \(new\):     $KERNELVER

read -p "Proceed? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo Update CHANGELOG
vim $ROOT/CHANGELOG.md

echo Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
sed -e "s/pkgrel=.*/pkgrel=${NEWPKGREL}/" -i $ROOT/aur/PKGBUILD
sed -e "s/pkgrel=.*/pkgrel=${NEWPKGREL}/" -i $ROOT/scripts/archlinux/PKGBUILD

echo Clean up
rm -rf $ROOT/build/archlinux
rm -rf $ROOT/build/debian
mkdir -p $ROOT/build/archlinux
mkdir -p $ROOT/build/debian

echo Build packages
cd ${ROOT}/scripts
./build.sh $KERNELVER

echo Build source
rm -rf $ROOT/build/linux
rsync -r --exclude '.git' $ROOT/build/linux-patched/ $ROOT/build/linux
cd ${ROOT}/build/linux
make clean
rm .config
ln -s ../../scripts/config .config

echo Commit and push
cd ${ROOT}
TAG="v$PKGVER-$NEWPKGREL"
git add .
git commit -m "release $TAG"
git push origin master
git tag $TAG
git push origin $TAG

echo Create github release
API_JSON=$(printf '{"tag_name": "%s","target_commitish": "master","name": "%s","body": "Release of version %s","draft": false,"prerelease": false}' $TAG $TAG $TAG)
curl --data "$API_JSON" https://api.github.com/repos/raphael/linux-samus/releases?access_token=`cat $ROOT/.githubtoken`

echo Build AUR package
cd ${ROOT}/aur
./update.sh

echo Push AUR package
cd ${ROOT}/aur/linux-samus4
rm v4*.tar.gz
git add .
git commit -m "release $TAG"
git push origin master

echo Update SHAs
head -n -3 $ROOT/aur/PKGBUILD > foo
cat foo > $ROOT/aur/PKGBUILD
rm foo
tail -n3 PKGBUILD >> $ROOT/aur/PKGBUILD

echo Replace version in README
sed -e "s/\*Current kernel version: .*/*Current kernel version: $KERNELVER*/" -i $ROOT/README.md

echo Push to master
cd ${ROOT}
git add .
git commit -m "release $TAG"
git push origin master
