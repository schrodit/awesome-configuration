#!/usr/bin/env bash

set -x
set -e
set -o pipefail

THEME_DIR="$(realpath $(dirname "$0"))"
wd="$(pwd)"

source "$THEME_DIR/helper.sh"

echo "Install X Server"
installWithPacman xorg-server xorg-xrandr xorg-xinput xbindkeys xsel acpilight
sudo cp "$THEME_DIR/xserver/00-keyboard.conf" /etc/X11/xorg.conf.d/00-keyboard.conf
createSymlink "$THEME_DIR/xserver/.xbindkeysrc" "$HOME/.xbindkeysrc"

echo "Install audio"
installWithPacman pulseaudio pamixer


echo "Install Awesome"
installWithPacman awesome luarocks
# only install for lua 5.3 as awesome is using lua 5.3
sudo luarocks install --lua-version 5.3 --server=http://luarocks.org/manifests/daurnimator ldbus DBUS_INCDIR=/usr/include/dbus-1.0/ DBUS_ARCH_INCDIR=/usr/lib/dbus-1.0/include
sudo luarocks install --lua-version 5.3 inspect
sudo luarocks install --lua-version 5.3 luafilesystem

echo "Install Lightdm"
installWithPacman lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan

sudo cp "$THEME_DIR/lightdm/lightdm.conf" /etc/lightdm/lightdm.conf
sudo cp "$THEME_DIR/lightdm/lightdm-webkit2-greeter.conf" /etc/lightdm/lightdm-webkit2-greeter.conf

sudo cp "$THEME_DIR/lightdm/sunset.jpg" /usr/share/backgrounds/sunset.jpg

sudo systemctl enable lightdm
