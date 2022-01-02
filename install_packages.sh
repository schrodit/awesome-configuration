#!/usr/bin/env bash

set -e
set -o pipefail

THEME_DIR="$(realpath $(dirname "$0"))"

wd="$(pwd)"

source "$THEME_DIR/helper.sh"

# creating temp aur repo
mkdir -p /aur
chown "$USER" /aur

if ! command -v yay &> /dev/null; then
    echo "Install yay"
    installWithPacman git base-devel

    cd /aur
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd "$wd"
fi

if ! command -v terminator &> /dev/null; then
    echo "Install terminator"
    installWithPacman termiantor
fi

echo "Install Rofi"
installWithPacman rofi

echo "Install Bluetooth"
installWithPacman bluez bluez-utils pulseaudio-bluetooth

echo "Download and start mpd (music player daemon)"
installWithPacman mpd playerctl # music player daemon
sudo systemctl enable mpd.service
sudo systemctl start mpd.service

echo "Install Google's roboto font"
installWithPacman ttf-roboto noto-fonts-emoji
cd ~/.fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
cd "$wd"

echo "Install Powerline Fonts"
installWithYay powerline-fonts-git

echo "Install Papirus Icon Theme"
installWithPacman papirus-icon-theme

