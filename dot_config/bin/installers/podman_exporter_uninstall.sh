#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

SERVICE_FILE="/etc/systemd/system/podman_exporter.service"
REPO_LOCATION="DEV/podman_exporter"
USER=$CURRENT_USER

# Function to delete the repository directory
delete_repo_directory() {
    echo_with_color "$RED_COLOR" "Deleting directory for podman_exporter..."
    if [ -d "$REPO_LOCATION" ]; then
        rm -rf "$REPO_LOCATION" || exit_with_error "Failed to delete directory: $REPO_LOCATION"
    else
        echo_with_color "$YELLOW_COLOR" "Directory $REPO_LOCATION does not exist."
    fi
}

# Function to stop and disable the systemd service
stop_and_disable_service() {
    echo_with_color "$RED_COLOR" "Stopping and disabling podman_exporter service..."
    if systemctl is-enabled --quiet podman_exporter; then
        sudo systemctl stop podman_exporter || exit_with_error "Failed to stop podman_exporter service."
        sudo systemctl disable podman_exporter || exit_with_error "Failed to disable podman_exporter service."
    else
        echo_with_color "$YELLOW_COLOR" "Service podman_exporter is not enabled."
    fi
}

# Function to delete the systemd service file
delete_systemd_service_file() {
    echo_with_color "$RED_COLOR" "Deleting Podman Exporter systemd service file..."
    if [ -f "$SERVICE_FILE" ]; then
        sudo rm "$SERVICE_FILE" || exit_with_error "Failed to delete service file: $SERVICE_FILE"
        sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
    else
        echo_with_color "$YELLOW_COLOR" "Service file $SERVICE_FILE does not exist."
    fi
}

# Main script
main() {
    if ! command_exists "systemctl"; then
        exit_with_error "Systemctl is not available. This script requires systemctl."
    fi

    stop_and_disable_service
    delete_systemd_service_file
    delete_repo_directory

    echo_with_color "$GREEN_COLOR" "Podman Exporter uninstallation completed successfully."
}

main