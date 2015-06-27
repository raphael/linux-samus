# Linux 4.1 Samus Build Scripts

This directory contains the scripts necessary to build the Samus 4.1 patched tree.
Simply run `build.sh` to build the patched tree under `../build/linux-patched`.
This script clones two entire linux trees to diff them, it takes a while to run...

The `archlinux` subdirectory contains scripts to build the ArchLinux package.

The `setup` subdirectory contains scripts that are helpful once the 4.1 kernel is
running. Namely it contains a script to help setup sound and another to control
screen brightness.
