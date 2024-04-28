#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

install_cargo_packages() {
    echo_with_color "$CYAN_COLOR" "Installing cargo packages..."

    while IFS= read -r package; do
        trimmed_package=$(echo "$package" | xargs)  # Trim whitespace from the package name
        if [ -n "$trimmed_package" ]; then  # Ensure the line is not empty
            output=$(cargo install "$trimmed_package" 2>&1)
            echo "$output"
            # if trimmed package is zellij and output is "error: failed to compile"
            if [[ "$trimmed_package" == "zellij" && "$output" == *"error: failed to compile"* ]]; then
                echo_with_color "$YELLOW_COLOR" "Failed to install ${trimmed_package}."
                echo_with_color "$YELLOW_COLOR" "Trying to install zellij with pkgx"
                    if pkgx install zellij; then
                        echo_with_color "$GREEN_COLOR" "zellij installed successfully."
                    else
                        echo_with_color "$RED_COLOR" "Failed to install zellij with pkgx."
                        echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
                    fi
            elif [[ "$output" == *"error"* ]]; then
                echo_with_color "$RED_COLOR" "Failed to install ${trimmed_package}."
                echo_with_color "$YELLOW_COLOR" "Continuing with the next package..."
            else
                echo_with_color "$GREEN_COLOR" "${trimmed_package} installed successfully."
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