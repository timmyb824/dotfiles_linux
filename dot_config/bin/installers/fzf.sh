#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Check if git is installed
if ! command_exists git; then
    exit_with_error "git is not installed - please install git and run this script again"
fi

# Check if basher is not already installed
if [ ! -d "$HOME/.fzf" ]; then
    echo "basher is not installed. Installing now..."
    if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
        echo_with_color "$GREEN_COLOR" "fzf cloned successfully; running installer"
        if ~/.fzf/install; then
            echo_with_color "$GREEN_COLOR" "fzf installed successfully"
            echo_with_color "$GREEN_COLOR" "Removing fzf directory"
            rm -rf ~/.fzf
        else
            exit_with_error "Failed to install fzf"
        fi
    else
        exit_with_error "Failed to clone fzf"
    fi
else
    echo_with_color "$BLUE_COLOR" "fzf is already installed at $HOME/.fzf"
fi
