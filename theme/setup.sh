#!/usr/bin/env bash

set -e

THEME_DIR=$(dirname "$0")

# sudo pacman -S networkmanager wget wireless_tools
# sudo systemctl enable NetworkManager.service
# sudo systemctl start NetworkManager.service

echo "Install Rofi"
sudo pacman -S rofi

echo "Download and start mpd (music player daemon)"
sudo pacman -S mpd # music player daemon
sudo systemctl enable mpd.service
sudo systemctl start mpd.service

echo "Install Google's roboto font"
sudo pacman -S ttf-roboto

echo "Installing Sweet Theme"

sweet_theme_url="https://github.com/EliverLara/Sweet/archive/refs/heads/master.tar.gz"
mkdir -p $HOME/.icons/sweet-assets
curl -L $sweet_theme_url | tar -C $HOME/.icons/Sweet --strip-components=1 -xzvf -

echo "Installing Candy Icons"
candy_icons_download_url="https://github.com/EliverLara/candy-icons/archive/refs/heads/master.tar.gz"
mkdir -p $HOME/.icons/candy-icons
curl -L $candy_icons_download_url | tar -C $HOME/.icons/candy-icons --strip-components=1 -xzvf -

