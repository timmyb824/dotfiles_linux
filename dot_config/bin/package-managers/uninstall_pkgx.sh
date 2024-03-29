#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to uninstall a package
uninstall_package() {
    local package=$1
    echo_with_color $BLUE_COLOR "Uninstalling ${package}..."
    if pkgx uninstall "${package}"; then
        echo_with_color $GREEN_COLOR "${package} uninstalled successfully."
    else
        echo_with_color $RED_COLOR "Failed to uninstall ${package}."
    fi
}

# Function to fetch and uninstall packages from a list
uninstall_packages_from_list() {
    local os_list=$1
    local package_list
    IFS=$'\n' read -r -d '' -a package_list < <(get_package_list "$os_list" && printf '\0')

    for package in "${package_list[@]}"; do
        uninstall_package "${package}"
    done
}

# Function to uninstall pkgx either the binary or via homebrew
uninstall_pkgx() {
    if command_exists pkgx; then
        echo_with_color $BLUE_COLOR "Uninstalling pkgx..."
        if command_exists brew; then
            brew uninstall pkgxdev/made/pkgx || exit_with_error "Uninstallation of pkgx using Homebrew failed."
        else
            sudo rm -f "$(command -v pkgx)" || exit_with_error "Uninstallation of pkgx failed."
        fi
    else
        echo_with_color $GREEN_COLOR "pkgx is not installed."
    fi
}

# Function to uninstall .pkgx directory
uninstall_pkgx_directory() {
    echo_with_color $BLUE_COLOR "Uninstalling .pkgx directory..."
    rm -rf "$HOME/.pkgx" || exit_with_error "Uninstallation of .pkgx directory failed."
}

echo_with_color $BLUE_COLOR "Starting the uninstallation process..."

# Uninstall all 'pkgx' packages first
uninstall_packages_from_list "pkgx"
uninstall_packages_from_list "pkgx_linux"
uninstall_pkgx
uninstall_pkgx_directory

echo_with_color $BLUE_COLOR "Uninstallation process completed."