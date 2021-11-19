# AwesomeWM theme

This repository contains my AwesomeWM configuration files.

The theme is mostly inspired by the `Powerarrow` theme in https://github.com/lcpz/awesome-copycats/tree/master/themes/powerarrow .


## Installation

```
git clone --recurse-submodules --remote-submodules --depth 1 -j 2 https://github.com/schrodit/awesome-configuration.git
mv -bv awesome-configuration/{*,.[^.]*} ~/.config/awesome; rm -rf awesome-configuration
```

Some modules require additional installed software.

Arch Installation for additonal packages:
```
pacman -S rofi # application launcher and window switcher
pacman -S mpd # music player daemon
sudo systemctl enable mpd.service
sudo systemctl start mpd.service

pacman -S ttf-roboto # use font
pacman -S mime-types # installs /etc/mime-types which is needed for freedesktop icons.

# Install icon theme
candy_icons_download_url="https://github.com/EliverLara/candy-icons/archive/refs/heads/master.tar.gz"
mkdir -p $HOME/.icons/candy-icons
curl -L $candy_icons_download_url | tar -C $HOME/.icons/candy-icons --strip-components=1 -xzvf -
```


- Sweet-Icons ([theme/icons/sweet-assets](./theme/icons/sweet-asset)) from https://github.com/EliverLara/Sweet 
- Wallpaper ([theme/dune.png](./theme/dune.png)) from https://www.pixel4k.com/dune-minimalist-4k-61834.html
- xrandr awesome vm script [xrandr.lua](xrandr.lua) from https://awesomewm.org/recipes/xrandr.lua
