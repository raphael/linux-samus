To build a new release:

1. Update CHANGELOG
2. Push all changes
3. Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
4. Tag with version e.g. "v4.1-3"
5. Create release in Github using tag
6. Build packages: cd scripts;./build.sh
7. Install new package, reboot and test
8. Build source: rm -rf build/linux;cp -r build/linux-patched build/linux; cd build/linux; make clean
9. Commit / push all packages using "release 4.1-x" message
10. Build AUR package: cd aur;./update.sh;vi linux-samus4/PKGBUILD
11. Push AUR package, install it and test

