#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to download and extract Nebula binaries
download_and_extract_nebula() {
  echo "Downloading Nebula..."
  curl -LO https://github.com/slackhq/nebula/releases/download/v1.9.3/nebula-linux-amd64.tar.gz
  tar -xzf nebula-linux-amd64.tar.gz
  sudo mv nebula /usr/local/bin/
  sudo mv nebula-cert /usr/local/bin/
}

# Function to set up the Lighthouse
setup_lighthouse() {
  echo "Setting up Lighthouse..."
  
  # Variables
  read -r -p "Enter the name for the Lighthouse (e.g., lighthouse1): " LH_NAME
  read -r -p "Enter the IP address for the Lighthouse (e.g., 192.168.100.1/24): " LH_IP
  read -r -p "Enter the routable IP address for the Lighthouse: " LH_ROUTABLE_IP
  
  # Create lighthouse certificate
  nebula-cert sign -name "$LH_NAME" -ip "$LH_IP"
  
  # Create config directory
  mkdir -p /etc/nebula
  
  # Download and configure example config
  curl -o /etc/nebula/config-lighthouse.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i 's/# am_lighthouse: false/am_lighthouse: true/' /etc/nebula/config-lighthouse.yaml
  sed -i "s/#static_host_map:/static_host_map:\n  '$LH_IP': ['$LH_ROUTABLE_IP:4242']/" /etc/nebula/config-lighthouse.yaml
  
  # Move certificates to config directory
  mv ca.crt /etc/nebula/
  mv "$LH_NAME".crt /etc/nebula/host.crt
  mv "$LH_NAME".key /etc/nebula/host.key
  mv /etc/nebula/config-lighthouse.yaml /etc/nebula/config.yaml
  
  # Start Nebula
  /usr/local/bin/nebula -config /etc/nebula/config.yaml
}

# Function to set up a regular host
setup_host() {
  echo "Setting up Host..."
  
  # Variables
  read -p "Enter the name for the Host (e.g., server): " HOST_NAME
  read -p "Enter the IP address for the Host (e.g., 192.168.100.9/24): " HOST_IP
  read -p "Enter the routable IP address for the Lighthouse: " LH_ROUTABLE_IP
  
  # Create host certificate
  nebula-cert sign -name "$HOST_NAME" -ip "$HOST_IP"
  
  # Create config directory
  mkdir -p /etc/nebula
  
  # Download and configure example config
  curl -o /etc/nebula/config.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i "s/#static_host_map:/static_host_map:\n  '192.168.100.1': ['$LH_ROUTABLE_IP:4242']/" /etc/nebula/config.yaml
  sed -i 's/# am_lighthouse: false/am_lighthouse: false/' /etc/nebula/config.yaml
  sed -i "s/# hosts:/hosts:\n    - '192.168.100.1'/" /etc/nebula/config.yaml
  
  # Move certificates to config directory
  mv ca.crt /etc/nebula/
  mv "$HOST_NAME".crt /etc/nebula/host.crt
  mv "$HOST_NAME".key /etc/nebula/host.key
  
  # Start Nebula
  /usr/local/bin/nebula -config /etc/nebula/config.yaml
}

# Main script logic
echo "Nebula Overlay Network Setup Script"
echo "==================================="
echo "1. Setup Lighthouse"
echo "2. Setup Host"
read -p "Choose an option (1 or 2): " OPTION

# Download and extract Nebula binaries
download_and_extract_nebula

# Create CA certificate if it does not exist
if [ ! -f ca.crt ]; then
  echo "Creating Certificate Authority..."
  nebula-cert ca -name "Myorganization, Inc"
fi

# Run appropriate setup function
case $OPTION in
  1)
    setup_lighthouse
    ;;
  2)
    setup_host
    ;;
  *)
    echo "Invalid option. Please run the script again and choose a valid option."
