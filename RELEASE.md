To build a new release:

1. Update CHANGELOG
2. Bump versions in scripts/archlinux/PKGBUILD and aur/PKGBUILD
3. Clean up: cd build/archlinux ; rm -rf * ; cd ../debian ; rm -rf * ; cd ../..
4. Build packages: cd scripts; ./build.sh v4.8.6
5. Install new package, reboot and test
6. Build source: cd ..;rm -rf build/linux;cp -r build/linux-patched build/linux; cd build/linux; rm -rf .git; make clean ; rm .config ; ln -s ../../scripts/config .config
7. Commit using "release 4.8-x" message: cd ../..;git add .; git commit -m "release v4.8-6"
8. Push: git push origin master
8. Tag with version "v4.8-x": git tag "v4.8-6"; git push origin "v4.8-6"
9. Create release in Github using tag
10. Build AUR package: cd aur;./update.sh
11. Push AUR package, install it and test: cd linux-samus4; rm v4\*.tar.gz; git add .; git commit -m "release v4.8-6"; git push origin master
12. Update aur/PKGBUILD with new SHAs: cat PKGBUILD # copy SHAs; cd ..; vi PKGBUILD # replace SHAs
13. Update version in README, push to master: cd ..; vi README; git add .; git commit -m "release v4.8-6"; git push origin master
