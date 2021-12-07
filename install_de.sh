#!/usr/bin/env bash

set -x
set -e
set -o pipefail

THEME_DIR="$(realpath $(dirname "$0"))"

wd="$(pwd)"

source "$THEME_DIR/helper.sh"

echo "Install X Server"
pacman -S xorg-server xorg-xrandr xorg-xinput
cp "$THEME_DIR/xserver/00-keyboard.conf" /etc/X11/xorg.conf.d/00-keyboard.conf

echo "Install Awesome"
pacman -S awesome

echo "Install Lightdm"
pacman -S lightdm lightdm-webkit2-greeter lightdm-webkit-theme-litarvan

cp "$THEME_DIR/lightdm/lightdm.conf" /etc/lightdm/lightdm.conf
cp "$THEME_DIR/lightdm/lightdm-webkit2-greeter.conf" /etc/lightdm/lightdm-webkit2-greeter.conf

systemctl enable lightdm
