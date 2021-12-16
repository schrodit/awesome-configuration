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
installWithPacman awesome

echo "Install Lightdm"
installWithPacman lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan

sudo cp "$THEME_DIR/lightdm/lightdm.conf" /etc/lightdm/lightdm.conf
sudo cp "$THEME_DIR/lightdm/lightdm-webkit2-greeter.conf" /etc/lightdm/lightdm-webkit2-greeter.conf

sudo cp "$THEME_DIR/lightdm/sunset.jpg" /usr/share/backgrounds/sunset.jpg

sudo systemctl enable lightdm
