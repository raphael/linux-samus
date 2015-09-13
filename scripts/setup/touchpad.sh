#!/bin/bash -ex

echo Compiling libgestures
git clone https://github.com/hugegreenbug/libgestures
cd libgestures
./apply_patches.sh
make -j4
echo Installing libgestures
sudo make install
cd ..
rm -rf libgestures

echo Compiling libevdevc
git clone https://github.com/hugegreenbug/libevdevc
cd libevdevc
make -j4
echo Installing libevdevc
sudo make install
cd ..
rm -rf libevdevc

echo Compiling xf86-input-cmt
git clone https://github.com/hugegreenbug/xf86-input-cmt
cd xf86-input-cmt
./apply_patches.sh
./configure --prefix=/usr
make -j4
echo Installing xf86-input-cmt
sudo make install

echo Configuring
sudo cp xorg-conf/40-touchpad-cmt.conf /usr/share/X11/xorg.conf.d/
sudo cp xorg-conf/50-touchpad-cmt-samus.conf /usr/share/X11/xorg.conf.d/
set +e
sudo mv /usr/share/X11/xorg.conf.d/50-synaptics.conf /usr/share/X11/xorg.conf/50-synaptics.conf.old 2>/dev/null


echo all done! - reboot or restart X
