#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_apt_packages() {
    echo_with_color "$CYAN_COLOR" "Installing apt packages..."

    sudo apt update || exit_with_error "Failed to update apt package list"

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            if sudo apt install -y "$trimmed_package"; then
                echo_with_color "$GREEN_COLOR" "${trimmed_package} installed successfully"
            else
                exit_with_error "Failed to install ${trimmed_package}"
            fi
        fi
    done < <(get_package_list apt.list)
}

# Ensure apt is installed
if ! command_exists apt; then
    echo_with_color "$RED_COLOR" "apt could not be found"

    exit_with_error "apt is required to install packages. Please install apt to continue."
fi

install_apt_packages