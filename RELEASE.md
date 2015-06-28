To build a new release:

1. Update CHANGELOG
2. Push all changes
3. Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
4. Tag with version e.g. "v4.1-3"
5. Create release in Github using tag
6. Build ArchLinux package: cd scripts/archlinux;./build.sh
7. Install new package, reboot and test
8. Build Debian package: cd scripts/debian;./build.sh
9. Build source: rm -rf build/linux;cp -r build/linux-patched build/linux; cd build/linux; make clean
10. Commit / push all packages
11. Change aur/PKGBUILD source to point to new release
12. Build AUR package: cd aur;./update.sh;vi linux-samus4/PKGBUILD
13. Push AUR package, install it and test

