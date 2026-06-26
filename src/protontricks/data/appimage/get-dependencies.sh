
#!/bin/sh

set -eu

ARCH=$(uname -m)

DEBLOATED_PKGS="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"
wget --retry-connrefused --tries=30 "$DEBLOATED_PKGS" -O ./get-debloated-pkgs

chmod +x ./get-debloated-pkgs

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
makepkg -p PKGBUILD-git -fsi --noconfirm

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
./get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
