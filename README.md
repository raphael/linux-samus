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

To enable sound run the `sound.sh` script:
```sh
$ cd linux-samus/scripts/setup/sound
$ ./sound.sh
```
> *NOTE* this scripts makes a number of assumptions on your system (e.g.
> `alsaucm` and `amixer` are both installed and the file
> /etc/pulse/default.pa contains a line to load the modules using udev).
If the setup script fails please see below "Enabling sound step-by-step".

##### User settings and control
To set the default sink from the laptop speakers when logged in, modify
the users pulseaudio config with:
```sh
$ pacmd set-default-sink 1
```
the following commands will toggle mute, increase volume, and decrease volume,
respectively.
```sh
$ pactl set-sink-mute 1 toggle
$ pactl set-sink-volume 1 -2%
$ pactl set-sink-volume 1 +2%
```

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

### Enabling sound step-by-step

If you're reading this either the `sound.sh` script failed or better you want to
understand what it does :)

The first thing to do is to copy over the firmwares from the `firmware` directory
to wherever your distribution installs firmwares (usually `/lib/firmware` or 
`/usr/lib/firmware`).

Next it's a good idea to make sure that the internal card driver always uses slot
0 in Alsa so that any PulseAudio configuration done later can reliably address the
card. This is done by adding a `.conf` file in `/etc/modprobe.d` containing the
following line:
```
options snd slots=snd_soc_sst_bdw_rt5677_mach,snd-hda-intel
```
At that point you may want to reboot.  Once rebooted check the output of `aplay -l`,
you should see something like:
```
**** List of PLAYBACK Hardware Devices ****
card 0: bdwrt5677 [bdw-rt5677], device 0: System Playback/Capture (*) []
  Subdevices: 1/1
  Subdevice #0: subdevice #0

```
If that's not what you are getting then check for errors in `dmesg`.

Once the driver loads correctly enable the "HiFi" verb with ALSAUCM. Make sure
alsaucm is installed. It's usually part of the "alsa-utils" package. Assuming
`alsaucm` is present, run the following:
```sh
$ cd scripts/setup
$ ALSA_CONFIG_UCM=ucm/ alsaucm -c bdw-rt5677 set _verb HiFi
```
Next the microphone driver must be loaded statically by PulseAudio, add the
lines:
```
load-module module-alsa-source device=hw:0,1
load-module module-alsa-source device=hw:0,2
```
to `/etc/pulse/default.pa` *before* the line
```
load-module module-udev-detect
```
Restart PulseAudio with:
```sh
$ pulseaudio -k && pulseaudio -D
```
If PulseAudio fails to restart running it in the foreground may produce helpful
output:
```
$ pulseaudio
```
Some users have also reported needing to configure PulseAudio to load the output
driver statically, this can be done by adding the following line in 
`/etc/pulse/default.pa`:
```
load-module module-alsa-sink device=hw:0,0
```

## Contributions

This repo exists so that we can all benefit from one another's work.
[Thomas Sowell's linux-samus](https://github.com/tsowell/linux-samus) repo
was both an inspiration and help in building it. The hope is that others
(you) will also feel inspired and contribute back. PRs are encouraged!
