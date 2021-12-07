
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