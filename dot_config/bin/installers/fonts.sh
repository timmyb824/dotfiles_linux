#!/usr/bin/env bash

# Include the init script
source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Check if font name is provided as argument
if [ -z "$1" ]; then
  exit_with_error "No font specified. Usage: ./fonts.sh <font>"
fi

# Function to install a Nerd Font
install_nerd_font() {
  local FONT_NAME=$1
  local FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/$FONT_NAME.zip"
  
  # Download the font zip file
  if wget "$FONT_URL" -O "$FONT_NAME.zip"; then
    echo_with_color "Downloaded $FONT_NAME; attempting to unzip"
    
    # Unzip the font zip file
    if unzip "$FONT_NAME.zip" -d "$FONT_NAME"; then
      echo_with_color "Unzipped $FONT_NAME; moving to ~/.local/share/fonts"
      
      # Move the font to the local fonts directory
      if mv "$FONT_NAME" ~/.local/share/fonts/; then
        echo_with_color "Moved $FONT_NAME; removing $FONT_NAME.zip"
        
        # Remove the downloaded zip file
        if rm "$FONT_NAME.zip"; then
          echo_with_color "Removed $FONT_NAME.zip; updating font cache"
          
          # Update the font cache
          if fc-cache -f -v; then
            echo_with_color "Successfully installed $FONT_NAME"
          else
            exit_with_error "Failed to update font cache"
          fi
        else
          exit_with_error "Failed to remove $FONT_NAME.zip"
        fi
      else
        exit_with_error "Failed to move $FONT_NAME"
      fi
    else
      exit_with_error "Failed to unzip $FONT_NAME.zip"
    fi
  else
    exit_with_error "Failed to download $FONT_NAME"
  fi
}

# Check for required commands
if ! command_exists unzip || ! command_exists wget || ! command_exists fc-cache; then
  exit_with_error "unzip, wget, and fc-cache are required"
fi

# Install the specified font
install_nerd_font "$1"
