#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

initialize_atuin() {
    echo_with_color "$YELLOW_COLOR" "Initializing atuin..."
    eval "$(atuin init "$(basename "$SHELL")")"
}

if command_exists atuin; then
    echo_with_color "$GREEN_COLOR" "atuin is already installed."
    if atuin status | grep -q "session not found"; then
        echo_with_color "$YELLOW_COLOR" "atuin is not logged in."
        if atuin login -u "$USER"; then
            echo_with_color "$GREEN_COLOR" "atuin login successful."
        else
            echo_with_color "$RED_COLOR" "atuin login failed."
            exit_with_error "Failed to log in to atuin with user $USER." 1
        fi
    else
        echo_with_color "$GREEN_COLOR" "atuin is already logged in."
    fi
else
    # Attempt to fix atuin command availability
    attempt_fix_command atuin "$HOME/.local/bin"

    # Check for atuin again
    if command_exists atuin; then
        echo_with_color "$YELLOW_COLOR" "Found atuin, initializing..."
        initialize_atuin
        if atuin login -u "$USER"; then
            echo_with_color "$GREEN_COLOR" "atuin login successful."
        else
            echo_with_color "$RED_COLOR" "atuin login failed."
            exit_with_error "Failed to log in to atuin with user $USER." 1
        fi
    else
        echo_with_color "$RED_COLOR" "atuin is still not found after attempting to fix the PATH."
        exit_with_error "Please install atuin to continue." 1
    fi
fi