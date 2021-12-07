#!/usr/bin/env bash

set -e
set -o pipefail

THEME_DIR="$(realpath $(dirname "$0"))"

wd="$(pwd)"

source "$THEME_DIR/helper.sh"

echo "Install General Utils"
sudo pacman -S fzf curl openssh jq

echo "Install Kubernetes Utils"

if ! command -v "kubectl" &> /dev/null
then
    echo "kubectl not found. Installing it..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client
    rm kubectl
fi

echo "Installing krew plugin manager"
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew

  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  kubectl krew install ns
)

echo "Install zsh theme"
createSymlink "$THEME_DIR/sh/schrodit.zsh-theme" "$HOME/.oh-my-zsh/themes/schrodit.zsh-theme"

createSymlink "$THEME_DIR/.aliases" "$HOME/.aliases"
createSymlink "$THEME_DIR/sh/.zshrc" "$HOME/.zshrc"

