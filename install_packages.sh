#!/usr/bin/env bash

set -e
set -o pipefail

THEME_DIR="$(realpath $(dirname "$0"))"

wd="$(pwd)"

# creating temp aur repo
mkdir -p /aur
chown "$USER" /aur

if ! command -v yay &> /dev/null; then
    echo "Install yay"
    sudo pacman -S --needed git base-devel

    cd /aur
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd "$wd"
fi

if ! command -v terminator &> /dev/null; then
    echo "Install terminator"
    sudo pacman -S termiantor
fi

echo "Install Rofi"
sudo pacman -S rofi

echo "Download and start mpd (music player daemon)"
sudo pacman -S mpd playerctl # music player daemon
sudo systemctl enable mpd.service
sudo systemctl start mpd.service

echo "Install Google's roboto font"
sudo pacman -S ttf-roboto noto-fonts-emoji

echo "Install Powerline Fonts"
yay -S powerline-fonts-git

echo "Install Papirus Icon Theme"
sudo pacman -S papirus-icon-theme

