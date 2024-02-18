#!/usr/bin/env bash

# Linux Tailscale Installation Script

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install Tailscale on Linux
install_tailscale_linux() {
    if ask_yes_or_no "Tailscale is not installed. Would you like to install Tailscale?"; then
        read -sp "Please enter your Tailscale authorization key: " TAILSCALE_AUTH_KEY
        echo

        if command_exists curl && command_exists lsb_release && command_exists sudo && command_exists tee; then
            echo_with_color "$COLOR_GREEN" "Installing Tailscale..."
            RELEASE=$(lsb_release -cs)
            if [ -z "$RELEASE" ]; then
                exit_with_error "Could not determine the distribution codename with lsb_release."
            fi

            # Add the Tailscale repository signing key and repository
            curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${RELEASE}.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
            curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${RELEASE}.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
        else
            exit_with_error "Required command(s) are missing. Please ensure curl, lsb_release, sudo, and tee are installed to proceed."
        fi

        # Update the package list and install Tailscale
        sudo apt-get update || exit_with_error "Failed to update package list. Exiting."
        sudo apt-get install tailscale -y || exit_with_error "Failed to install Tailscale. Exiting."

        # Start Tailscale and authenticate
        sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
    else
        echo_with_color "$COLOR_BLUE" "Skipping Tailscale installation."
    fi
}

# Main execution
if command_exists tailscale; then
    status=$(tailscale status || true)
    if [[ "$status" =~ "Tailscale is stopped." ]]; then
        echo_with_color "$COLOR_BLUE" "Tailscale is installed but stopped. Starting Tailscale..."
        read -sp "Please enter your Tailscale authorization key: " TAILSCALE_AUTH_KEY
        echo
        sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --operator="$USER"
    else
        echo_with_color "$COLOR_GREEN" "Tailscale is running."
    fi
else
    install_tailscale_linux
fi