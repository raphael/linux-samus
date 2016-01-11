#!/bin/bash -ex

echo Compiling libgestures
git clone https://github.com/hugegreenbug/libgestures
cd libgestures
make -j4
echo Installing libgestures
sudo make install
cd ..

echo Compiling libevdevc
git clone https://github.com/hugegreenbug/libevdevc
cd libevdevc
make -j4
echo Installing libevdevc
sudo make install
cd ..

echo Compiling xf86-input-cmt
git clone https://github.com/hugegreenbug/xf86-input-cmt
cd xf86-input-cmt
./configure --prefix=/usr
make -j4
echo Installing xf86-input-cmt
sudo make install

echo Configuring
if [[ ! -f /usr/share/X11/xorg.conf.d/40-touchpad-cmt.conf ]]; then
  sudo cp xorg-conf/40-touchpad-cmt.conf /usr/share/X11/xorg.conf.d/
fi
if [[ ! -f /usr/share/X11/xorg.conf.d/50-touchpad-cmt-samus.conf ]]; then
  sudo cp xorg-conf/50-touchpad-cmt-samus.conf /usr/share/X11/xorg.conf.d/
fi
set +e


sudo rm -rf libgestures
sudo rm -rf libevdevc
sudo rm -rf xf86-input-cmt
sudo mv /usr/share/X11/xorg.conf.d/50-synaptics.conf /usr/share/X11/xorg.conf/50-synaptics.conf.old 2>/dev/null
echo all done! - reboot or restart X
