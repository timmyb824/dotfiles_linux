#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install rbenv using the official installer script on Linux
install_rbenv_linux() {
  echo_with_color "32" "Installing rbenv and dependencies on Linux..."
  sudo apt update || exit_with_error "Failed to update apt."
  sudo apt install -y git curl autoconf bison build-essential libssl-dev libyaml-dev \
    libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev ||
    exit_with_error "Failed to install dependencies for rbenv and Ruby build."
  curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
}

# Function to initialize rbenv within the script
initialize_rbenv() {
  echo_with_color "32" "Initializing rbenv for the current Linux session..."
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
}

# Function to install Ruby and set it as the global version
install_and_set_ruby() {
  echo_with_color "32" "Installing Ruby version $RUBY_VERSION..."
  rbenv install $RUBY_VERSION || exit_with_error "Failed to install Ruby version $RUBY_VERSION."
  echo_with_color "32" "Setting Ruby version $RUBY_VERSION as global..."
  rbenv global $RUBY_VERSION || exit_with_error "Failed to set Ruby version $RUBY_VERSION as global."
  echo "Ruby installation completed. Ruby version set to $RUBY_VERSION."
}

# Main execution
if command_exists rbenv; then
  echo_with_color "32" "rbenv is already installed."
else
  install_rbenv_linux || exit_with_error "Failed to install rbenv."
fi

initialize_rbenv
install_and_set_ruby