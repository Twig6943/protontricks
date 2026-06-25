#!/bin/sh

set -eu

ARCH=$(uname -m)
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
DEBLOATED_PKGS="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

if [ -n "${GITHUB_REF_NAME:-}" ] && [ "${GITHUB_REF_TYPE:-}" = "tag" ]; then
    VERSION="${GITHUB_REF_NAME}"
else
    VERSION=$(pacman -Q protontricks-git | awk '{print $2; exit}')
fi
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
#export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/com.github.Matoking.protontricks.svg
export DESKTOP=/usr/share/applications/com.github.Matoking.protontricks.desktop

#Remove leftovers
rm -rf AppDir dist

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$DEBLOATED_PKGS" -O ./get-debloated-pkgs
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun ./get-debloated-pkgs

# Debloated pkgs
#./get-debloated-pkgs --add-common --prefer-nano

# Deploy dependencies
./quick-sharun /usr/bin/protontricks /usr/bin/protontricks-launch

# Turn AppDir into AppImage
./quick-sharun --make-appimage
