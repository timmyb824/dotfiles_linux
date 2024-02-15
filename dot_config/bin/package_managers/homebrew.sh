#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install Homebrew on macOS
install_brew_macos() {
    if ! command_exists brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        add_brew_to_path
    else
        echo "Homebrew is already installed."
    fi

    if ! command_exists brew; then
        exit_with_error "Homebrew installation failed or PATH setup was not successful."
    fi
}

# Function to update PATH for the current session
add_brew_to_path() {
    # Determine the system architecture for the correct Homebrew path
    local BREW_PREFIX
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew/bin"
    else
        BREW_PREFIX="/usr/local/bin"
    fi

    # Construct the Homebrew path line
    local BREW_PATH_LINE="eval \"$(${BREW_PREFIX}/brew shellenv)\""

    # Check if Homebrew PATH is already in the PATH
    if ! echo "$PATH" | grep -q "${BREW_PREFIX}"; then
        echo "Adding Homebrew to PATH for the current session..."
        eval "${BREW_PATH_LINE}"
    fi
}

# Prompt the user to install packages using Homebrew
install_packages_with_brew() {
    if ask_yes_or_no "Do you want to install the packages from the Brewfile?"; then
        brew bundle --file="dot_config/bin/package-managers/Brewfile"
    else
        echo "Skipping package installation."
    fi
}

# Main execution for macOS
if [[ "$(get_os)" == "macOS" ]]; then
    safe_remove_command "/usr/local/bin/op"
    install_brew_macos
    install_packages_with_brew
else
    exit_with_error "This script is intended for use on macOS only."
fi