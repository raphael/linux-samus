To build a new release:

* Tag with version e.g. "v1.3"
* Push tag
* Create release in Github
* Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
* Build ArchLinux package: cd scripts/archlinux;./build.sh
* Install new package, reboot and test
* Build Debian package: cd scripts/debian;./build.sh
* Commit / push all changes
* Build AUR package: cd aur;./build.sh;vi linux-samus4/PKGBUILD
* Push AUR package, install it and test

