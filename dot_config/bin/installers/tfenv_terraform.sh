#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install tfenv on Linux
tfenv_install_linux() {
    if ! command_exists git; then
        exit_with_error "git not found. Please install git first."
    else
        # Clone tfenv into ~/.tfenv
        git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
        # Create symlink in a directory that is on the user's PATH
        # Ensure the directory exists and is on PATH
        TFENV_BIN="$HOME/.local/bin"
        mkdir -p "$TFENV_BIN"
        ln -s ~/.tfenv/bin/* "$TFENV_BIN"
        # Add directory to PATH if it's not already there
        add_to_path_exact_match "$TFENV_BIN"
        if ! command_exists tfenv; then
            exit_with_error "tfenv installation failed."
        fi
    fi
}

# Main script execution
if [[ "$(get_os)" == "Linux" ]]; then
    if [[ -z "${TF_VERSION}" ]]; then
        exit_with_error "TF_VERSION is not set. Please set TF_VERSION to the desired Terraform version."
    fi

    # Check if Terraform is installed and working
    if ! command_exists terraform; then
        echo_with_color "33" "Terraform could not be found."
        tfenv_install_linux
        echo_with_color "32" "Successfully installed tfenv. Attempting to install Terraform ${TF_VERSION}..."
        if tfenv install "${TF_VERSION}"; then
            installed_version=$(terraform version | head -n 1)
            echo_with_color "32" "Installed Terraform version $installed_version successfully."
            if tfenv use "${TF_VERSION}"; then
                echo_with_color "32" "Terraform ${TF_VERSION} is now in use."
            else
                exit_with_error "Failed to use Terraform ${TF_VERSION}, please check tfenv setup."
            fi
        else
            exit_with_error "Failed to install Terraform ${TF_VERSION}, please check tfenv setup."
        fi
    else
        echo_with_color "32" "Terraform is already installed and working."
    fi
else
    exit_with_error "This script is intended for use on Linux only."
fi