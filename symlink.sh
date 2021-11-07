#!/usr/bin/env bash

set -e

# Creates a symlink of all files to the awesome directory.

THEME_DIR="$(realpath $(dirname "$0"))"
AWESOME_DIR="$HOME/.config/awesome"

links=( "theme" "awesome-wm-widgets" "freedesktop" "lain" "xrandr.lua" "rc.lua" )

rc_file="$AWESOME_DIR/rc.lua"
backup_rc_file="$AWESOME_DIR/rc.lua.bak"
if [[ -f "$rc_file" ]]; then
    if [[ ! -f "$backup_rc_file" ]]; then
        echo "Create a backup of the old rc.lua"
        mv "$AWESOME_DIR/rc.lua" "$AWESOME_DIR/rc.lua.bak"
    fi
fi

for link in "${links[@]}"
do

    link_name="$AWESOME_DIR/$link"
    target_link="$THEME_DIR/$link"

    if [[ -L "$link_name" ]]; then
        echo "Delete already existing $link_name"
        rm "$link_name"
    fi

    echo "Link ${target_link} to ${link_name}"
    ln -s -f $target_link $link_name
done
