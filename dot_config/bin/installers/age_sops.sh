#!/usr/bin/env bash

# Define safe_remove_command function and other necessary utilities
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install sops on Linux
install_sops_linux() {
    echo "Downloading sops binary for Linux..."
    SOPS_BINARY="sops-${SOPS_VERSION}.linux.amd64"
    curl -LO "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/${SOPS_BINARY}"
    sudo mv "$SOPS_BINARY" /usr/local/bin/sops
    sudo chmod +x /usr/local/bin/sops
    echo "sops installed successfully on Linux."
}

# Function to install age on Linux
install_age_linux() {
    echo "Downloading age binary for Linux..."
    curl -LO "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz"
    tar -xvf "age-${AGE_VERSION}-linux-amd64.tar.gz"
    sudo mv age/age /usr/local/bin/age
    rm -rf age
    echo "age installed successfully on Linux."
}

# Check and install sops if not installed
if command_exists sops; then
    echo "sops is already installed on Linux."
else
    install_sops_linux
fi

# Check and install age if not installed
if command_exists age; then
    echo "age is already installed on Linux."
else
    install_age_linux
fi