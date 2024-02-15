#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to install pyenv and Python dependencies for Linux
install_pyenv_linux() {
    echo_with_color "32" "Installing pyenv and Python dependencies for Linux..."
    sudo apt update
    sudo apt install -y build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    curl https://pyenv.run | bash
}

# Function to install and set up Python version using pyenv
setup_python_version() {
    if pyenv install "${PYTHON_VERSION}"; then
        echo_with_color "32" "Python ${PYTHON_VERSION} installed successfully."

        if pyenv global "${PYTHON_VERSION}"; then
            echo_with_color "32" "Python ${PYTHON_VERSION} is now in use."
        else
            exit_with_error "Failed to set Python ${PYTHON_VERSION} as global, please check pyenv setup."
        fi
    else
        exit_with_error "Failed to install Python ${PYTHON_VERSION}, please check pyenv setup."
    fi
}

initialize_pyenv() {
    # Initialize pyenv for the current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
}

# Main installation process
if ! command_exists pyenv; then
    echo_with_color "32" "pyenv could not be found."

    if [[ "$(get_os)" == "Linux" ]]; then
        install_pyenv_linux
        initialize_pyenv
        setup_python_version
    else
        exit_with_error "Unsupported operating system: $(get_os)"
    fi
else
    echo_with_color "32" "pyenv is already installed."
    initialize_pyenv
    # Assuming that Python version is already set
fi