# Linux 4.1 samus (Chromebook Pixel 2015)

This repository contains scripts that create a linux kernel patch from the
ChromiumOS 3.14 tree (that's the version used to create the Pixel 2 kernel)
and a small set of custom changes necessary to make the code compatible
with the 4.1 tree. The current version is `4.1-rc8`.

The main features the patches enable are sound support as well as screen and
keyboard backlight. The provided kernel config is also somewhat optimized
for the Pixel 2.

## Usage

There are two ways the patches can be applied: use the prepatched tree
or build your own (e.g. if you need a different version than 4.1-rc8).

The easy way is to simply compile and install the pre-patched kernel found in
`build/linux`. A set of Arch Linux packages is also included for convenience
in `build/archlinux` with an install script under `scripts/archlinux`.

### Arch Linux
```
$ cd scripts/archlinux
$ ./install.sh
```
### Other distributions
```
$ cd build/linux
$ make nconfig
$ make -j4
$ sudo make modules_install
$ sudo make install
```
> *NOTE* The steps above are just the standard kernel build steps and may
> differ depending on your setup. In particular the default kernel makefile
> assumes LILO is being used.

### Post-install steps

Once installed reboot and load the kernel. To enable sound, run `alsaucm` as
follows:
```
$ cd linux-4.1-pixel
$ ALSA_CONFIG_UCM=scripts/ucm/ alsaucm -c bdw-rt5677 set _verb HiFi
```
To enable the microphone follow the steps in the first FAQ entry.

### Building your own patch

To build your own patched tree use the `build.sh` scripts located in the
`scripts` folder. The script accepts an optional argument which corresponds 
to the git tag of the kernel tree to build the patch against. The default
value is `4.1-rc8`.

This script clones the two trees, diffs the necessary files and applies the
patch containing the custom changes (`monkey.patch`) to the result. This
process results in a patched tree located in `scripts/linux-head`.

## FAQ

### 1. Microphone Support

While ALSA detects the microphone device just fine, PulseAudio doesn't. The
fix is simple though and consists of adding the following line in the file
`/etc/pulseaudio/default.pa`:
```
load-module module-alsa-source device=hw:1,1
```
This line must be added *before* the line that reads:
```
load-module module-udev-detect
```

### 2. Resume fails after STR (Suspend-To-Ram)

The TPM module must be loaded for resume to work after suspend. The config
included in this repository enables it by default.

### 3. Hibernate/Swap doesn't work

The kernel config included in this repository disables swap as the Pixel 2
is generous on memory but not so much on disk space. Hibernate requires
swap. If you need support for swap simply edit the config using e.g.
`make nconfig` in the `build/linux` directory, go to `General setup` and
enable `Support for paging of anonymous memory (swap)`.

### 4. LVM / Encrypted partition doesn't boot

The kernel config in this repo doesn't enable LVM support which is required
if the encryption is using cryptsetup a.k.a. DMCrypt.
If you need support enable the corresponding options in Drivers -->
Multiple devices driver support (RAID and LVM) --> Device mapper support.

## Contributions

This repo exists so that we can all benefit from each other's work.
[Thomas Sowell's linux-samus](https://github.com/tsowell/linux-samus) repo
was both an inspiration and help in building it. The hope is that others
(you) will also feel inspired and contribute back. PRs are encouraged!


