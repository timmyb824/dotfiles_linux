#!/bin/bash

# Check if a service name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

# Service name is the first argument
SERVICE_NAME="$1"

# Stop the user service
systemctl --user stop "$SERVICE_NAME"

# Disable the user service
systemctl --user disable "$SERVICE_NAME"

# Remove the user service file
rm -f "$HOME/.config/systemd/user/${SERVICE_NAME}.service"

# Reload the daemon in case the file removal needs to be recognized
systemctl --user daemon-reload

# Extract the container name from the service name
CONTAINER_NAME=$(echo "$SERVICE_NAME" | sed -r 's/^container-(.*)\.service/\1/')

# Stop and remove the container
podman stop "$CONTAINER_NAME"
podman rm "$CONTAINER_NAME"

echo "Service and container for $SERVICE_NAME have been removed."
