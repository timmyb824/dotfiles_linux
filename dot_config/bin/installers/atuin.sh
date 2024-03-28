#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

initialize_atuin() {
    echo_with_color "$YELLOW_COLOR" "Initializing atuin..."
    eval "$(atuin init bash)"
}

login_to_atuin() {
    if atuin status &> /dev/null; then
        if atuin status | grep -q "cannot show sync status"; then
            echo_with_color "$YELLOW_COLOR" "atuin is not logged in."
            if atuin login -u "$ATUIN_USER"; then
                echo_with_color "$GREEN_COLOR" "atuin login successful."
            else
                echo_with_color "$RED_COLOR" "atuin login failed."
                exit_with_error "Failed to log in to atuin with user $ATUIN_USER." 2
            fi
        else
            echo_with_color "$GREEN_COLOR" "atuin is already logged in."
        fi
    else
        echo_with_color "$RED_COLOR" "Unable to determine atuin status. Please check atuin configuration."
        exit_with_error "Unable to determine atuin status." 1
    fi
}

install_and_configure_atuin() {
    if command_exists atuin; then
        echo_with_color "$GREEN_COLOR" "atuin is already installed."
        login_to_atuin
    else
        initialize_cargo
        echo_with_color "$YELLOW_COLOR" "Installing atuin with cargo..."
        if cargo install atuin; then
            echo_with_color "$GREEN_COLOR" "atuin installed successfully."
            initialize_atuin
            login_to_atuin
        else
            echo_with_color "$RED_COLOR" "Failed to install atuin."
            exit_with_error "Failed to install atuin with cargo." 1
        fi
    fi
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

# Main execution
install_and_configure_atuin