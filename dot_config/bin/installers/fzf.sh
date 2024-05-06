#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

uninstall_fzf_apt() {
    if [ -f /usr/bin/fzf ]; then
        echo_with_color "$YELLOW_COLOR" "fzf is already installed at /usr/bin/fzf"
        echo_with_color "$YELLOW_COLOR" "Uninstalling fzf"
        sudo apt remove fzf -y || exit_with_error "Failed to uninstall fzf"
        echo_with_color "$YELLOW_COLOR" "fzf uninstalled successfully"
    else
        echo_with_color "$YELLOW_COLOR" "fzf is not installed at /usr/bin/fzf"
    fi
}

install_fzf() {
    if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
        echo_with_color "$GREEN_COLOR" "fzf cloned successfully; running installer"
        if ~/.fzf/install; then
            echo_with_color "$GREEN_COLOR" "fzf installed successfully"
        else
            exit_with_error "Failed to install fzf"
        fi
    else
        exit_with_error "Failed to clone fzf"
    fi
}

clone_fzf_git() {
    if command_exists ghq; then
        ghq get https://github.com/junegunn/fzf-git.sh || exit_with_error "Failed to clone fzf-git.sh"
    else
        exit_with_error "ghq is not installed - please install ghq and run this script again"
    fi
}

install_fdfind() {
    if ! command_exists fd; then
        if command_exists cargo; then
            cargo install fd-find || exit_with_error "Failed to install fd-find"
        else
            exit_with_error "cargo is not installed - please install cargo and run this script again"
        fi
    else
        echo_with_color "$YELLOW_COLOR" "fd is already installed"
    fi
}

# Check if git is installed
if ! command_exists git; then
    exit_with_error "git is not installed - please install git and run this script again"
fi

uninstall_fzf_apt
install_fzf
clone_fzf_git
install_fdfind
