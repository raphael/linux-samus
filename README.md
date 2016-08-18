# Linux for Chromebook Pixel 2015
[![Chat with us on #linux-samus on freenode.net](https://img.shields.io/badge/chat-on%20%23linux--samus-brightgreen.svg)](https://webchat.freenode.net/?channels=linux-samus "Chat with us on #linux-samus on freenode.net")

This repository contains packages for Debian and Arch Linux that installs the Linux kernel 4.7 with
a set of patches that enable sound support. The Linux 4.7 kernel has built-in support for the Pixel
screen and keyboard leds as well as its touchpad and touchscreen. This makes the Pixel 2015 fully
supported with this kernel tree.

The patches that were built in this repo in prior releases are no longer needed as support for the
sound card has (finally) been submitted upstream. This repo temporarily includes the upstream patches
and a patched tree until they make it in an official Linux release. See https://lkml.org/lkml/2016/8/14/207.

The provided kernel config is also somewhat optimized for the Pixel 2015.

*Current kernel version: 4.7*

## Installation

The easiest way to get going is to install the packages if you are running
Ubuntu, Debian or Arch Linux.

### Ubuntu / Debian

``` bash
$ git clone --depth=1 https://github.com/raphael/linux-samus
$ cd linux-samus/build/debian
$ sudo dpkg -i *.deb
```

### Arch Linux

Install the [`linux-samus4`](https://aur.archlinux.org/packages/linux-samus4/) package from the AUR:
```sh
$ yaourt -S linux-samus4
```

### Other distributions

The entire kernel patched tree is located under `build/linux`, compile and install using the usual
instructions for installing kernels. For example:
``` bash
$ git clone --depth=1 https://github.com/raphael/linux-samus
$ cd linux-samus/build/linux
$ make nconfig
$ make -j4
$ sudo make modules_install
$ sudo make install
```
> *NOTE* the steps above are just the standard kernel build steps and may
> differ depending on your distro/setup.

## Post-install steps

Once installed reboot and load the kernel.

### Sound

##### User settings and control

The following commands will toggle mute, decrease volume and increase volume,
respectively.
```sh
amixer -q -D pulse sset Master toggle
amixer -q -D pulse sset Master 5%-
amixer -q -D pulse sset Master 5%+
```

##### Users upgrading from pre-4.7 Samus kernel

To get sound working, you must unwind some of the previous samus sound settings:

1) edit the file `/etc/pulse/default.pa` and ensure these lines are commentted out:
```
#load-module module-alsa-sink device=hw:0,0
#load-module module-alsa-source device=hw:0,1
#load-module module-alsa-source device=hw:0,2
```
2) remove the following folders:  `/opt/samus`  and  `/usr/share/alsa/ucm/bdw-rt5677`  
3) edit the file `/etc/acpi/handler.sh` and remove any samus entries  

NOTE: settings to toggle headphone/speaker during `plug)` and `unplug)` events still need to be implemented.

### Touchpad

Since Linux 4.3 the Atmel chip needs to be reconfigured to guarantee that the touchpad works.
See [issue #73](../../issues/73) for details. The `linux-samus/scripts/setup/touchpad` directory contains a script
that does the reconfig:
```sh
$ cd linux-samus/scripts/setup/touchpad
$ ./enable-atmel.sh
```

This is only needed to be run once.

### Xorg

To enable X11 acceleration run the `xaccel.sh` script:
```sh
$ cd linux-samus/scripts/setup/xorg
$ ./xaccel.sh
```

### Brightness

The script `scripts/setup/brightness/brightness` can be used to control the
brightness level.
```sh
$ cd scripts/setup/brightness
$ ./brightness --help
Increase or decrease screen brighness
Usage: brightness --increase | --decrease
```
Put `scripts/setup/brightness` in your path and bind the F6 key to
`brightness --decrease` and the F7 key to `brightness --increase` for an
almost native experience.

Similarly the script `script/setup/brightness/keyboard_led` can be used to
control the keyboard backlight, bind the ALT-F6 key to
`keyboard_led --decrease` and ALT-F7 to `keyboard_led --increase`.

Both these scripts require write access to files living under `/sys` which
get mounted read-only for non-root users on boot by default. If your system
uses `systemd` (e.g. ArchLinux) then the file
`script/setup/brightness/enable-brightness.service` contains the definition
for a systemd service that makes the files above writable to non-root user.
Run `systemctl enable enable-brightness.service` for the service to run on boot.

##### systemd
```sh
./setup.systemd.sh
```
The same directory also contains `setup.systemd.sh`. When executed, it copies
scripts to `/usr/local/bin` and configures systemd to run the script
`enable-brightness.sh` on boot.

##### OpenRC
```sh
./setup.openrc.sh
```
The same directory also contains `setup.openrc.sh`. When executed, it copies
scripts to `/usr/local/bin` and configures OpenRC to run the script
`enable-brightness.sh` on boot using the `local` service.

## Contributions

This repo exists so that we can all benefit from one another's work.
[Thomas Sowell's linux-samus](https://github.com/tsowell/linux-samus) repo
was both an inspiration and help in building it. The hope is that others
(you) will also feel inspired and contribute back. PRs are encouraged!
