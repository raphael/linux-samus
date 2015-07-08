To build a new release:

1. Update CHANGELOG
2. Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
3. Build packages: cd scripts;./build.sh
4. Install new package, reboot and test
5. Build source: rm -rf build/linux;cp -r build/linux-patched build/linux; cd build/linux; make clean
6. Commit / push all packages using "release 4.1-x" message
7. Tag with version "v4.1-x"
8. Create release in Github using tag
9. Build AUR package: cd aur;./update.sh;vi linux-samus4/PKGBUILD
10. Push AUR package, install it and test

