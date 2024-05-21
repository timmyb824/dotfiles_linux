#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

if ! command_exists "curl" || ! command_exists "unzip"; then
    echo "curl and unzip are required"
    exit 1
fi

install_the_font() {
    local font_name="JetBrainsMono"
    local font_version="2.304"
    local font_url="https://download.jetbrains.com/fonts/JetBrainsMono-$font_version.zip"
    local font_path="$HOME/.local/share/fonts/$font_name"

    if [ -f "$font_path" ]; then
        echo "Font $font_name is already installed"
        return
    fi

    echo "Installing font $font_name"
    mkdir -p "$font_path" || exit_with_error "Failed to create font directory"
    curl -L -o "$font_path" "$font_url" || exit_with_error "Failed to download font $font_name"
    unzip -o "$font_path" -d "$font_path" || exit_with_error "Failed to unzip font $font_name"
    fc-cache -f -v "$font_path" || exit_with_error "Failed to update font cache"
    echo_with_color "$GREEN_COLOR" "Font $font_name has been installed"
}

install_the_font
