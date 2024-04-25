#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_cargo_packages() {
    echo_with_color "$CYAN_COLOR" "Installing cargo packages..."

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            if cargo install --locked "$trimmed_package"; then
                echo_with_color "$GREEN_COLOR" "${trimmed_package} installed successfully"
            else
                exit_with_error "Failed to install ${trimmed_package}"
            fi
        fi
    done < <(get_package_list cargo_linux.list)
}

initialize_cargo() {
    if command_exists cargo; then
        echo_with_color "$GREEN_COLOR" "cargo is already installed."
    else
        echo_with_color "$YELLOW_COLOR" "Initializing cargo..."
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        else
            echo_with_color "$RED_COLOR" "Cargo environment file does not exist."
            exit_with_error "Please install cargo to continue." 1
        fi

        if ! command_exists cargo; then
            echo_with_color "$RED_COLOR" "Cargo is still not found after attempting to fix the PATH."
            exit_with_error "Please install cargo to continue." 1
        fi
    fi
}

initialize_cargo
install_cargo_packages