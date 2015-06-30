# Linux 4.1 samus (Chromebook Pixel 2015)

This repository contains scripts that create a linux kernel patch from the
ChromiumOS 3.14 tree (that's the version used to create the Pixel 2 kernel)
and a small set of custom changes necessary to make the code compatible
with the 4.1 tree.

The main features the patches enable are sound support as well as screen and
keyboard backlight. The provided kernel config is also somewhat optimized
for the Pixel 2.

## Installation

There are two ways the patches can be applied: use the prepatched tree
or build your own (e.g. if you need a different version than 4.1).

### Ubuntu / Debian
```
$ git clone https://github.com/raphael/linux-4.1-samus
$ cd linux-4.1-samus/build/debian
$ sudo dpkg -i *.deb
```
### Arch Linux
Install from the AUR4:
```
yaourt -S linux-samus4 --aur-url https://aur4.archlinux.org
```
or from repo:
```
$ git clone https://github.com/raphael/linux-4.1-samus
$ cd linux-4.1-samus/scripts/archlinux
$ ./install.sh
```
### Other distributions
The entire kernel patched tree is located under `build/linux`, compile and install using the usual
instructions for installing kernels. For example:
```
$ git clone https://github.com/raphael/linux-4.1-samus
$ cd linux-4.1-samus/build/linux
$ make nconfig
$ make -j4
$ sudo make modules_install
$ sudo make install
```
> *NOTE* the steps above are just the standard kernel build steps and may
> differ depending on your distro/setup. In particular the default kernel makefile
> assumes LILO is being used. Follow the instructions specific to your
> distribution for installing kernels from source.

## Post-install steps

Once installed reboot and load the kernel.

To enable sound run the `sound.sh` script:
```
$ cd linux-4.1-samus/scripts/setup
$ ./sound.sh
```
> *NOTE* this scripts makes a number of assumptions on your system (e.g.
> `alsaucm` and `amixer` are both installed and the file
> /etc/pulse/default.pa contains a line to load the modules using udev).
If the setup script fails please see the #1 FAQ "Enabling sound step-by-step".

To enable X11 acceleration run the `xaccel.sh` script:
```
$ cd linux-4.1-samus/scrupts/setup
$ ./xaccel.sh
```

The script `script/setup/brightness` can be used to control the brightness level.
```
$ script/setup/brightness --help
Increase or decrease screen brighness
Usage: brightness --increase | --decrease
```
Bind the F6 key to `brightness --decrease` and the F7 key to `brightness --increase` for
an almost native experience...

### Building your own patch

To build your own patched tree use the `patch.sh` scripts located in the
`scripts` folder. The script accepts an optional argument which corresponds 
to the git tag of the kernel tree to build the patch against. The default
value is `4.1`.

This script clones the two trees, diffs the necessary files and create a
patch. It then applies this generated patch and the other included patches
to the original tree. This process results in a patched tree located in
`build/linux-patched`.

## FAQ

### 1. Enabling sound step-by-step

If you're reading this either the `sound.sh` script failed or better you want to
understand what it does :)

The first thing to do is to enable the "HiFi" verb with ALSAUCM. Make sure
alsaucm is installed. It's usually part of the "alsa-utils" package. Assuming
`alsaucm` is present, run the following:
```
$ cd scripts/setup
$ ALSA_CONFIG_UCM=ucm/ alsaucm -c bdw-rt5677 set _verb HiFi
```
Next the microphone driver must be loaded statically by PulseAudio, add the
lines:
```
load-module module-alsa-source device=hw:1,1
load-module module-alsa-source device=hw:1,2
```
to `/etc/pulseaudio/default.pa` *before* the line
```
load-module module-udev-detect
```
The last thing to check is the volume level for the mic in ALSA. If the mic
doesn't seem to pick up any sound run the following command:
```
$ amixer -c1 set Mic "60%"
```

### 2. Resume fails after STR (Suspend-To-Ram)

The TPM module must be loaded for resume to work after suspend. The config
included in this repository and the pre-built packages enable it by default.
Note that there's no need to pass in the tpm kernel option like there was
with the 3.x kernels.

### 3. Hibernate/Swap doesn't work

The kernel config included in this repository disables swap as the Pixel 2
is generous on memory but not so much on disk space. Hibernate requires
swap. If you need support for swap simply edit the config using e.g.
`make nconfig` in the `build/linux` directory, go to `General setup` and
enable `Support for paging of anonymous memory (swap)`.

## Contributions

This repo exists so that we can all benefit from each other's work.
[Thomas Sowell's linux-samus](https://github.com/tsowell/linux-samus) repo
was both an inspiration and help in building it. The hope is that others
(you) will also feel inspired and contribute back. PRs are encouraged!


