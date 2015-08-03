To build a new release:

1. Update CHANGELOG
2. Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
3. Clean up: cd build/archlinux ; rm -rf * ; cd ../debian ; rm -rf * ; cd ../..
4. Build packages: cd scripts; ./build.sh linux-stable v4.1 v4.1.4
5. Install new package, reboot and test
6. Build source: rm -rf build/linux;cp -r build/linux-patched build/linux; cd build/linux; rm -rf .git; make clean ; rm .config ; ln -s ../../scripts/config .config
7. Commit / push all packages using "release 4.1-x" message
8. Tag with version "v4.1-x"
9. Create release in Github using tag
10. Build AUR package: cd aur;./update.sh;vi linux-samus4/PKGBUILD
11. Push AUR package, install it and test
12. Update aur/PKGBUILD with new SHAs, push to master

