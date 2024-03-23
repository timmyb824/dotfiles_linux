#!/usr/bin/env bash

# Source necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to check if Podman is installed
check_podman_installed() {
    if command_exists podman; then
        echo_with_color "32" "Podman is already installed."
        podman --version
        return 0
    else
        return 1
    fi
}

initialize_pip_linux() {
    if command_exists pip; then
        echo_with_color "$GREEN_COLOR" "pip is already installed."
        return
    fi

    local pip_path="$HOME/.pyenv/shims/pip"
    if [[ -x "$pip_path" ]]; then
        echo_with_color "$GREEN_COLOR" "Adding pyenv pip to PATH."
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    else
        echo_with_color "$YELLOW_COLOR" "pip is not installed. Please run pyenv_python.sh first."
        exit_with_error "pip installation required"
    fi
}

# Function to install Podman
install_podman() {
    # Ensure sudo is available
    if ! command_exists sudo; then
        echo_with_color "31" "sudo command is required but not found. Please install sudo first."
        return 1
    fi

    # Install Podman
    if ! sudo apt-get update || ! sudo apt-get install -y podman; then
        echo_with_color "31" "Failed to install Podman."
        return 1
    fi

    # Install podman-compose using pip
    if ! command_exists pip; then
        echo_with_color "31" "pip is not installed. Attempting to install pip..."
        initialize_pip_linux

    fi
    if ! pip install --user podman-compose; then
        echo_with_color "31" "Failed to install podman-compose."
        return 1
    fi

    echo_with_color "32" "Podman and podman-compose installed successfully."

    echo_with_color "33" "Configuring Podman..."
    # Update registries to include docker.io
    local config_dir="$HOME/.config/containers"
    mkdir -p "$config_dir"

    if ! cp /etc/containers/registries.conf "$config_dir/"; then
        echo_with_color "31" "Failed to copy registries.conf file to $config_dir."
        return 1
    fi

    if ! echo "unqualified-search-registries = [\"docker.io\"]" >>"$config_dir/registries.conf"; then
        echo_with_color "31" "Failed to add docker.io to registry configuration."
        return 1
    fi

    # Enable containers to run after logout
    if ! sudo loginctl enable-linger "$USER"; then
        echo_with_color "31" "Failed to enable lingering for user $USER."
        return 1
    fi

    # Allow containers use of HTTP/HTTPS ports
    local sysctl_conf="/etc/sysctl.d/podman-privileged-ports.conf"
    echo "# Lowering privileged ports to allow us to run rootless Podman containers on lower ports" | sudo tee "$sysctl_conf"
    echo "# From: www.smarthomebeginner.com" | sudo tee -a "$sysctl_conf"
    echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee -a "$sysctl_conf"

    if ! sudo sysctl --load "$sysctl_conf"; then
        echo_with_color "31" "Failed to apply sysctl configuration for privileged ports."
        return 1
    fi

    echo_with_color "32" "Podman configuration completed successfully."
}

# Main script execution
if check_podman_installed; then
    echo_with_color "32" "Skipping installation as Podman is already installed."
else
    echo_with_color "33" "Podman is not installed. Installing Podman..."
    install_podman
fi
