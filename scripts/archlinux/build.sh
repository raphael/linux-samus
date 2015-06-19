#!/bin/bash

# 1. Build
makepkg --check -f -L -p PKGBUILD
if [ $? -ne 0 ]; then
  exit 1
fi

# 2. Save results
mv *.xz ../../build/archlinux

# 3. Clean
rm -rf src
rm -rf pkg
rm -rf *.log
rm -rf *.log.1
rm -f linux.install.pkg

# 4. Profit
echo Packages successfully built in `readlink -f ../../build/archlinux`
