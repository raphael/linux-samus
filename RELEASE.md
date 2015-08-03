To build a new release:

1. Update CHANGELOG
2. Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
3. Build packages: cd build/archlinux ; rm -rf * ; cd ../debian ; rm -rf * ; cd ../../scripts; ./build.sh linux-stable v4.1
4. Install new package, reboot and test
5. Build source: rm -rf build/linux;cp -r build/linux-patched build/linux; cd build/linux; rm -rf .git; make clean ; rm .config ; ln -s ../../scripts/config .config
6. Commit / push all packages using "release 4.1-x" message
7. Tag with version "v4.1-x"
8. Create release in Github using tag
9. Build AUR package: cd aur;./update.sh;vi linux-samus4/PKGBUILD
10. Push AUR package, install it and test
11. Update aur/PKGBUILD with new SHAs, push to master

