#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_go_packages() {
    echo_with_color "$CYAN_COLOR" "Installing go packages..."

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            if go install "$trimmed_package"; then
                echo_with_color "$GREEN_COLOR" "${trimmed_package} installed successfully"
            else
                exit_with_error "Failed to install ${trimmed_package}"
            fi
        fi
    done < <(get_package_list go_linux.list)
}


if command_exists go; then
    echo_with_color "$CYAN_COLOR" "Go is installed, installing go packages..."
    install_go_packages
else
    echo_with_color "$RED_COLOR" "Go is not installed, skipping go packages installation..."
    exit_with_error "Please install Go to continue."
fi