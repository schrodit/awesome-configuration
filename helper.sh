
# creates a symlink and removed the file if it already exists
function createSymlink() {
    local link_name=$2
    local target_link=$1

    if [[ -L "$link_name" ]]; then
        echo "Delete already existing link $link_name"
        rm "$link_name"
    fi

    if [[ -f "$link_name" ]]; then
        echo "Delete already existing file $link_name"        
        mv "$link_name" "$link_name.backup"
    fi

    echo "Link ${target_link} to ${link_name}"
    ln -sf $target_link $link_name
}

# creates a symlink and removed the file if it already exists using sudo
function sudoCreateSymlink() {
    local link_name=$2
    local target_link=$1

    if [[ -L "$link_name" ]]; then
        echo "Delete already existing link $link_name"
        sudo rm "$link_name"
    fi

    if [[ -f "$link_name" ]]; then
        echo "Delete already existing file $link_name"        
        sudo mv "$link_name" "$link_name.backup"
    fi

    echo "Link ${target_link} to ${link_name}"
    sudo ln -sf $target_link $link_name
}

# installs a package using yay if it is not already installed
function installWithYay() {
    for pkg in "$@"
    do
        if ! pacman -Qi $pkg &> /dev/null; then
            yay -S $pkg
        else
            echo "Package $pkg already installed. Skipping..."
        fi
    done
}

# installs a package using pacman if it is not already installed
function installWithPacman() {
    for pkg in "$@"
    do
        if ! pacman -Qi $pkg &> /dev/null; then
            sudo pacman -S $pkg
        else
            echo "Package $pkg already installed. Skipping..."
        fi
    done
}
