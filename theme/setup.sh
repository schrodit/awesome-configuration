#!/usr/bin/env bash

set -e

THEME_DIR=$(dirname "$0")

echo "Download and start mpd (music player daemon)"
sudo pacman -S mpd # music player daemon
sudo systemctl enable mpd.service
sudo systemctl start mpd.service

echo "Install Google's roboto font"
sudo pacman -S ttf-roboto

#echo "Installing Sweet Theme"

#sweet_theme_url="https://github.com/EliverLara/Sweet/archive/refs/heads/master.tar.gz"
#mkdir -p $THEME_DIR/icons/sweet-assets
#curl -L $sweet_theme_url | tar -C $THEME_DIR/icons/sweet-assets --strip-components=2 -xzvf - Sweet-master/assets

echo "Installing Candy Icons"
candy_icons_download_url="https://github.com/EliverLara/candy-icons/archive/refs/heads/master.tar.gz"
mkdir -p $HOME/.icons/candy-icons
curl -L $candy_icons_download_url | tar -C $HOME/.icons/candy-icons --strip-components=1 -xzvf -

