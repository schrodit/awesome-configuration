#!/usr/bin/env bash

set -x
set -e
set -o pipefail

THEME_DIR=$(dirname "$0")

echo "> Install packages"
$THEME_DIR/install_packages.sh


echo "> Install Desktop Environment"
$THEME_DIR/install_de.sh
$THEME_DIR/awesome/symlink.sh

echo "> Install Utils"
sudo $THEME_DIR/install_utils.sh
