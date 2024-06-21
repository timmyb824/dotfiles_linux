#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

SERVICE_FILE="/etc/systemd/system/podman_exporter.service"
REPO_LOCATION="DEV/podman_exporter"
USER=$CURRENT_USER

clone_podman_exporter() {
    echo_with_color "$GREEN_COLOR" "Creating directory for podman_exporter..."
    mkdir -p "$REPO_LOCATION" || exit_with_error "Failed to create directory: $REPO_LOCATION"
    echo_with_color "$GREEN_COLOR" "Cloning podman_exporter..."
    git clone https://github.com/containers/prometheus-podman-exporter.git "$REPO_LOCATION" || exit_with_error "Failed to clone podman_exporter."
    chmod +x "$REPO_LOCATION/bin/prometheus-podman-exporter" || exit_with_error "Failed to make prometheus-podman-exporter executable."
}

# Function to create systemd service file
create_systemd_service_file() {
    echo_with_color "$GREEN_COLOR" "Creating Podman Exporter systemd service file..."

    sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Podman Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
WorkingDirectory=$REPO_LOCATION
ExecStart=$REPO_LOCATION/bin/prometheus-podman-exporter --collector.enable-all
Restart=always
RestartSec=30s
TimeoutSec=30s

[Install]
WantedBy=multi-user.target

EOL
}

start_podman_exporter_service() {
    echo_with_color "$GREEN_COLOR" "Starting podman service..."
    sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
    sudo systemctl enable --now podman_exporter || exit_with_error "Failed to enable and start podman service."
    sudo systemctl status --no-pager podman_exporter || exit_with_error "Failed to check podman service status."
    echo_with_color "$GREEN_COLOR" "podman_exporter service started successfully."
}

# Main script
main() {
    if ! command_exists "podman"; then
        exit_with_error "Podman is not installed. Please install Podman first."
    fi

    if ! command_exists "git"; then
        exit_with_error "Git is not installed. Please install Git first."
    fi

    clone_podman_exporter
    create_systemd_service_file
    start_podman_exporter_service

    echo_with_color "$GREEN_COLOR" "Podman Exporter installation completed successfully."
}

main