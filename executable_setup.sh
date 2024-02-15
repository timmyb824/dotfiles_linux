#!/usr/bin/env bash

# Execute with bash: `bash setup.sh`

# Source the common functions
source "dot_config/bin/init/init.sh"

# Define the path to the scripts
SCRIPT_DIR="dot_config/bin"
INSTALL_PACKAGES_SCRIPT="dot_config/bin/install.sh"

# Function to install chezmoi
install_chezmoi() {
    if command_exists chezmoi; then
        echo_with_color "32" "chezmoi is already installed."
        return 0
    fi

    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS chezmoi.io/get)" -- -b "$HOME/.local/bin"
    echo_with_color "32" "chezmoi installed."
}

# Function to initialize and apply chezmoi dotfiles
initialize_chezmoi() {
    echo "Initializing and applying chezmoi dotfiles..."
    chezmoi init --apply timmyb824
}

package_installation() {
    if ask_yes_or_no "Do you want to install the packages?"; then
        if [ -f "$INSTALL_PACKAGES_SCRIPT" ] && [ -x "$INSTALL_PACKAGES_SCRIPT" ]; then
            echo "Running package installation script."
            "$INSTALL_PACKAGES_SCRIPT" || exit_with_error "Failed to execute package installation."
        else
            exit_with_error "Package installation script does not exist or is not executable."
        fi
    else
        echo "Package installation skipped."
    fi
}

run_setup_scripts() {
    local script=$1
    echo "Running $script..."
    "$SCRIPT_DIR/$script" || exit_with_error "Failed to run $script."
    echo_with_color "32" "$script completed."
}

# Check if chezmoi and .zshrc already exist
if [[ -d "$HOME/.local/share/chezmoi" && -f "$HOME/.zshrc" ]]; then
    echo_with_color "33" "It appears chezmoi is already installed and initialized."
else
    install_chezmoi
    initialize_chezmoi
fi

package_installation

# Additional setup scripts can be run here as needed
# Example:
# run_setup_scripts "some_additional_script.sh"