#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"


install_nvim_linux() {
    NVIM_RELEASE="nvim-linux64.tar.gz"
    NVIM_BIN_LOCATION="/usr/local/bin/nvim"
    if curl -LO https://github.com/neovim/neovim/releases/latest/download/${NVIM_RELEASE}; then
        sudo tar -xvf $NVIM_RELEASE
        sudo mv nvim-linux64/bin/nvim $NVIM_BIN_LOCATION
        sudo chmod +x $NVIM_BIN_LOCATION
        sudo rm -rf nvim-linux64 $NVIM_RELEASE
        echo_with_color "$GREEN_COLOR" "Neovim installed successfully on Linux."
    else
        echo_with_color "$RED_COLOR" "Error: The Neovim download failed."
        return 1
    fi
}

uninstall_existing_nvim() {
if [ -f /usr/bin/nvim ]; then
    echo_with_color "$YELLOW_COLOR" "Removing the existing Neovim installation..."
    if sudo apt remove -y neovim; then
        echo_with_color "$GREEN_COLOR" "Neovim removed successfully."
    else
        echo_with_color "$RED_COLOR" "Error: Failed to remove the existing Neovim installation."
        exit 1
    fi
fi
}

if ! command_exists curl; then
    echo_with_color "$BLUE_COLOR" "Installing the 'curl' command..."
    sudo apt update && sudo apt install -y curl
fi

uninstall_existing_nvim
install_nvim_linux