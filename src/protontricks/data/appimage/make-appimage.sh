#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q protontricks | awk '{print $2; exit}') # example command to get version of application here

SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun

export ARCH VERSION
#export APPDIR="$PWD/AppDir"
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
#export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/com.github.Matoking.protontricks.svg
export DESKTOP=/usr/share/applications/protontricks.desktop
export LIB_DIR=/usr/lib
export DEPLOY_PYTHON=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1

# Deploy dependencies
quick-sharun \
	/usr/bin/*tricks*        \
	/usr/lib/libopenjp2.so*  \
	/usr/lib/libtiff.so*     \
	/usr/lib/libimagequant.so* \
	/usr/bin/zenity \
	/usr/bin/yad

echo 'unset VK_DRIVER_FILES' >> ./AppDir/.env
# Fix python symlinks to point to 3.11 which has the stdlib bundled
rm -f ./AppDir/shared/bin/python ./AppDir/shared/bin/python3
ln -s python3.11 ./AppDir/shared/bin/python
ln -s python3.11 ./AppDir/shared/bin/python3

# Install protontricks and its Python dependencies into the AppDir's Python 3.11
SITE_PACKAGES="$PWD/AppDir/lib/python3.11/site-packages"
python3.11 -m venv /tmp/protontricks-venv
/tmp/protontricks-venv/bin/pip install --target="$SITE_PACKAGES" --no-deps vdf Pillow
rsync -a --exclude='data/appimage' "$PWD/../../" "$SITE_PACKAGES/protontricks/"
rm -rf /tmp/protontricks-venv

cc -shared -fPIC -O2 -o ./AppDir/lib/execve-sharun-hack.so execve-sharun-hack.c -ldl
echo 'execve-sharun-hack.so' >> ./AppDir/.preload
echo 'export ANYLINUX_EXECVE_WRAP_PATHS="$DATADIR:$HOME/.steam"' >> ./AppDir/bin/execve-wrap-path.hook

# Additional changes can be done in between here

# Turn AppDir into AppImage
./quick-sharun --make-appimage
