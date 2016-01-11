# Linux for Chromebook Pixel 2015

This repository contains packages for Debian and Arch Linux that installs
the Linux kernel 4.3 with a set of patches that enable sound support as
well as keyboard and screen brightness control. The Linux kernel 4.3
already has built-in support for the touchpad making the Pixel 2 fully
supported with this kernel tree.

The repository also contains the complete source for the patched kernel
tree so that it can be built and installed on other Linux distributions.

The set of scripts used to create the patched linux kernel source is also
included. These scripts diff the ChromiumOS 3.14 tree (that's the version
used to create the Pixel 2 ChromeOS kernel) with the 4.3 tree and apply
a small set of custom changes necessary to make the code compatible.

The provided kernel config is also somewhat optimized for the Pixel 2.

*Current kernel version: 4.3.3*

## Installation

The easiest way to get going is to install the packages if you are running
Ubuntu, Debian or Arch Linux.

### Ubuntu / Debian
``` bash
$ git clone https://github.com/raphael/linux-samus
$ cd linux-samus/build/debian
$ sudo dpkg -i *.deb
```
### Arch Linux
Install from the AUR:
```
yaourt -S linux-samus4
```
### Other distributions
The entire kernel patched tree is located under `build/linux`, compile and install using the usual
instructions for installing kernels. For example:
``` bash
$ git clone https://github.com/raphael/linux-samus
$ cd linux-samus/build/linux
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
### Sound
To enable sound run the `sound.sh` script:
``` bash
$ cd linux-samus/scripts/setup/sound
$ ./sound.sh
```
> *NOTE* this scripts makes a number of assumptions on your system (e.g.
> `alsaucm` and `amixer` are both installed and the file
> /etc/pulse/default.pa contains a line to load the modules using udev).
If the setup script fails please see below "Enabling sound step-by-step".
### Touchpad
Since linux 4.3 the atmel chip needs to be reset on boot to guarantee that the touchpad works.
See issue #73 for details. The linux-samus/scripts/setup/touchpad directory contains a script
that does the reset:
```bash
$ cd linux-samus/scripts/setup/touchpad
$ ./enable-atmel.sh
```
The directory also contains the definition of a systemd service that invokes the script
automatically on boot. Setup the service with the `setup-service.sh` script.
### Xorg
To enable X11 acceleration run the `xaccel.sh` script:
``` bash
$ cd linux-samus/scripts/setup/xorg
$ ./xaccel.sh
```
### Brightness
The script `script/setup/brightness/brightness` can be used to control the brightness level.
```
$ cd scripts/setup/brightness
$ ./brightness --help
Increase or decrease screen brighness
Usage: brightness --increase | --decrease
```
Bind the F6 key to `brightness --decrease` and the F7 key to `brightness --increase` for
an almost native experience... (assuming the scripts are in your path).

Similarly the script `script/setup/brightness/keyboard_led` can be used to control the keyboard backlight,
bind the ALT-F6 key to `keyboard_led --decrease` and ALT-F7 to `keyboard_led --increase`.

Both these scripts require write access to files living under `/sys` which get mounted
read-only for non-root users on boot by default. If your system uses `systemd` (e.g. ArchLinux)
then the file `script/setup/brightness/enable-brightness.service` contains the definition for a systemd
service that makes the files above writable to non-root user. Run
`systemctl enable enable-brightness.service` for the service to run on boot.

### Building your own patch

To build your own patched tree use the `patch.sh` scripts located in the
`scripts` folder. The script accepts two arguments which correspond
to the git branch and tag of the kernel tree to build the patch against. Example:
```
./patch.sh 4.3 4.3.4
```
This script clones the two trees, diffs the necessary files and create a
patch. It then applies this generated patch and the other included patches
to the original tree. This process results in a patched tree located in
`build/linux-patched`.

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
card 0: bdwrt5677 [bdw-rt5677], device 0: System Playback (*) []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: HDMI [HDA Intel HDMI], device 3: HDMI 0 [HDMI 0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: HDMI [HDA Intel HDMI], device 7: HDMI 1 [HDMI 1]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: HDMI [HDA Intel HDMI], device 8: HDMI 2 [HDMI 2]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```
If that's not what you are getting then check for errors in `dmesg`.

Once the driver loads correctly enable the "HiFi" verb with ALSAUCM. Make sure
alsaucm is installed. It's usually part of the "alsa-utils" package. Assuming
`alsaucm` is present, run the following:
``` bash
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
```
$ pulseaudio -k && pulseaudio -D
```
If PulseAudio fails to restart running it in the foreground may produce helpful
output:
```
$ pulseaudio
```
Assuming PulseAudio restarted successfully the last thing to do is to restore the alsa state:
```
$ cd scripts/setup
$ sudo alsactl restore --file alsa/asound.state
```
Some users have also reported needing to configure PulseAudio to load the output
driver statically, this can be done by adding the following line in 
`/etc/pulse/default.pa`:
```
load-module module-alsa-sink device=hw:0,0
```

## Contributions

This repo exists so that we can all benefit from each other's work.
[Thomas Sowell's linux-samus](https://github.com/tsowell/linux-samus) repo
was both an inspiration and help in building it. The hope is that others
(you) will also feel inspired and contribute back. PRs are encouraged!


