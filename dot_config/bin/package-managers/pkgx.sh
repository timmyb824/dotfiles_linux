#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pkgx
install_pkgx() {
    if ! command_exists curl; then
        echo_with_color "34" "Installing curl..."
        sudo apt-get update || exit_with_error "Failed to update apt-get."
        sudo apt-get install -y curl || exit_with_error "Installation of curl failed."
    fi

    if command_exists curl; then
        echo_with_color "34" "Installing pkgx using curl..."
        curl -Ssf https://pkgx.sh | sh || exit_with_error "Installation of pkgx using curl failed."
    else
        exit_with_error "curl is still not installed. Cannot install pkgx."
    fi
}

# Check if pkgx is installed, if not then install it
if ! command_exists pkgx; then
    echo_with_color "31" "pkgx could not be found"
    install_pkgx
fi

# Verify if pkgx was successfully installed
command_exists pkgx || exit_with_error "pkgx installation failed."

# Fetch the list of packages to install using get_package_list
packages=( $(get_package_list pkgx) )

# Linux specific packages
if [ "$(get_os)" = "Linux" ]; then
    # Append additional Linux-specific packages to the list
    packages+=( $(get_package_list pkgx_linux) )
fi

# Binary paths (edit these as per your system)
mc_bin_path="$HOME/.local/bin/mc"
mcomm_bin_path="$HOME/.local/bin/mcomm"

echo_with_color "34" "Installing packages..."

# Iterate over the packages and install one by one
for package in "${packages[@]}"; do
    # Capture the output of the package installation
    output=$(pkgx install "${package}" 2>&1)

    if [[ "${output}" == *"pkgx: installed:"* ]]; then
        echo_with_color "32" "${package} installed successfully"

        # If the package is mc (Midnight Commander), rename the binary
        if [ "${package}" = "midnight-commander.org" ]; then
            mv "${mc_bin_path}" "${mcomm_bin_path}" || exit_with_error "Failed to rename mc binary to mcomm."
            echo_with_color "32" "Renamed mc binary to mcomm"
        fi
    elif [[ "${output}" == *"pkgx: already installed:"* ]]; then
        echo_with_color "34" "${package} is already installed."
    else
        echo_with_color "31" "Failed to install ${package}: $output"
    fi
done

# Add $HOME/.local/bin to PATH if it's not already there
add_to_path "$HOME/.local/bin"