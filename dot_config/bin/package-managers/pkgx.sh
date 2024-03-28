#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pkgx
install_pkgx() {
    # Ensure curl is installed before attempting to install pkgx
    if ! command_exists curl; then
        echo_with_color "$GREEN_COLOR" "curl is not installed. Installing curl..."
        sudo apt-get update || exit_with_error "Failed to update apt-get."
        sudo apt-get install -y curl || exit_with_error "Installation of curl failed."
    fi

    echo_with_color "$BLUE_COLOR" "Installing pkgx using curl..."
    curl -Ssf https://pkgx.sh | sh || exit_with_error "Installation of pkgx using curl failed."
}

# Install pkgx if it's not already available
if ! command_exists pkgx; then
    echo_with_color "$RED_COLOR" "pkgx could not be found"
    install_pkgx
fi

# Verify pkgx installation
command_exists pkgx || exit_with_error "pkgx installation failed."

# Check if the current user is privileged and set the appropriate package list
if is_privileged_user; then
    # Fetch the list of all packages for privileged users
    packages=( $(get_package_list pkgx) )
    packages+=( $(get_package_list pkgx_linux) ) # Add Linux specific packages
else
    # Fetch the list of limited packages for non-privileged users
    packages=( $(get_package_list pkgx_limited) )
fi

# Define binary paths
mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo_with_color "$CYAN_COLOR" "Installing packages..."

# Install packages using pkgx
for package in "${packages[@]}"; do
    output=$(pkgx install "${package}" 2>&1)

    if [[ "$output" == *"pkgx: installed:"* ]]; then
        echo_with_color "$GREEN_COLOR" "${package} installed successfully"
        # Check if the package is "midnight-commander.org", and user is privileged
        if [[ "${package}" == "midnight-commander.org" ]] && is_privileged_user; then
            mv "$mc_bin_path" "$mcomm_bin_path" || exit_with_error "Failed to rename mc binary to mcomm."
            echo_with_color "$BLUE_COLOR" "Renamed mc binary to mcomm"
        fi
    elif [[ "$output" == *"pkgx: already installed:"* ]]; then
        echo_with_color "$YELLOW_COLOR" "${package} is already installed."
    else
        exit_with_error "Failed to install ${package}: $output"
    fi
done

# Add local binary path to PATH
add_to_path "$HOME/.local/bin"
