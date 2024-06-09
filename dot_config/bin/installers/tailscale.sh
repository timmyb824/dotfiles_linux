#!/usr/bin/env bash

# Linux Tailscale Installation Script

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install Tailscale on Linux
install_tailscale_linux() {
    if command_exists curl && command_exists lsb_release && command_exists sudo; then
        echo_with_color "$GREEN_COLOR" "Installing Tailscale..."
        local RELEASE
        local DISTRO
        RELEASE=$(lsb_release -cs)
        DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
        if [ -z "$RELEASE" ]; then
            exit_with_error "Could not determine the distribution codename with lsb_release."
        fi

        # Add the Tailscale repository signing key and repository
        curl -fsSL "https://pkgs.tailscale.com/stable/${DISTRO}/${RELEASE}.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL "https://pkgs.tailscale.com/stable/${DISTRO}/${RELEASE}.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list

        # Update the package list and install Tailscale
        sudo apt-get update || exit_with_error "Failed to update package list. Exiting."
        sudo apt-get install tailscale -y || exit_with_error "Failed to install Tailscale. Exiting."

        # Start Tailscale and authenticate
        authenticate_tailscale
    else
        exit_with_error "Required command(s) are missing. Please ensure curl, lsb_release, and sudo are installed to proceed."
    fi
}

authenticate_tailscale() {
    read -sp "Please enter your Tailscale authorization key: " TAILSCALE_AUTH_KEY
    echo
    if sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"; then
        echo_with_color "$GREEN_COLOR" "Tailscale has started successfully."
    else
        exit_with_error "Failed to start Tailscale with the provided authorization key."
    fi
}

# Main execution
if command_exists tailscale; then
    status=$(tailscale status || true)
    if [[ "$status" == *"Tailscale is stopped."* ]]; then
        echo_with_color "$BLUE_COLOR" "Tailscale is installed but stopped. Starting Tailscale..."
        authenticate_tailscale
    elif [[ "$status" == *"logged out"* ]]; then
        echo_with_color "$BLUE_COLOR" "Tailscale is installed but not logged in. Authenticating..."
        authenticate_tailscale
    else
        echo_with_color "$GREEN_COLOR" "Tailscale is running."
    fi
else
    echo_with_color "$BLUE_COLOR" "Tailscale is not installed. Proceeding with installation..."
    install_tailscale_linux
fi