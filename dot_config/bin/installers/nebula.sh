#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to download and extract Nebula binaries
download_and_extract_nebula() {
  printf "Downloading Nebula...\n"
  curl -LO https://github.com/slackhq/nebula/releases/download/v1.9.3/nebula-linux-amd64.tar.gz
  tar -xzf nebula-linux-amd64.tar.gz
  sudo mv nebula /usr/local/bin/
  sudo mv nebula-cert /usr/local/bin/
}

# Function to set up the Lighthouse
setup_lighthouse() {
  printf "Setting up Lighthouse...\n"
  
  # Variables
  read -r -p "Enter the name for the Lighthouse (e.g., lighthouse1): " lh_name
  read -r -p "Enter the IP address for the Lighthouse (e.g., 192.168.100.1/24): " lh_ip
  read -r -p "Enter the routable IP address for the Lighthouse: " lh_routable_ip
  
  # Create lighthouse certificate
  nebula-cert sign -name "$lh_name" -ip "$lh_ip"
  
  # Create config directory
  mkdir -p /etc/nebula
  
  # Download and configure example config
  curl -o /etc/nebula/config-lighthouse.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i 's/# am_lighthouse: false/am_lighthouse: true/' /etc/nebula/config-lighthouse.yaml
  sed -i "s/#static_host_map:/static_host_map:\n  '$lh_ip': ['$lh_routable_ip:4242']/" /etc/nebula/config-lighthouse.yaml
  
  # Move certificates to config directory
  mv ca.crt /etc/nebula/
  mv "$lh_name".crt /etc/nebula/host.crt
  mv "$lh_name".key /etc/nebula/host.key
  mv /etc/nebula/config-lighthouse.yaml /etc/nebula/config.yaml
  
  # Start Nebula
  /usr/local/bin/nebula -config /etc/nebula/config.yaml
}

# Function to set up a regular host
setup_host() {
  printf "Setting up Host...\n"
  
  # Variables
  read -p "Enter the name for the Host (e.g., server): " host_name
  read -p "Enter the IP address for the Host (e.g., 192.168.100.9/24): " host_ip
  read -p "Enter the routable IP address for the Lighthouse: " lh_routable_ip
  
  # Create host certificate
  nebula-cert sign -name "$host_name" -ip "$host_ip"
  
  # Create config directory
  mkdir -p /etc/nebula
  
  # Download and configure example config
  curl -o /etc/nebula/config.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i "s/#static_host_map:/static_host_map:\n  '192.168.100.1': ['$lh_routable_ip:4242']/" /etc/nebula/config.yaml
  sed -i 's/# am_lighthouse: false/am_lighthouse: false/' /etc/nebula/config.yaml
  sed -i "s/# hosts:/hosts:\n    - '192.168.100.1'/" /etc/nebula/config.yaml
  
  # Move certificates to config directory
  mv ca.crt /etc/nebula/
  mv "$host_name".crt /etc/nebula/host.crt
  mv "$host_name".key /etc/nebula/host.key
  
  # Start Nebula
  /usr/local/bin/nebula -config /etc/nebula/config.yaml
}

# Main script logic
main() {
  printf "Nebula Overlay Network Setup Script\n"
  printf "===================================\n"
  printf "1. Setup Lighthouse\n"
  printf "2. Setup Host\n"
  read -p "Choose an option (1 or 2): " option

  # Download and extract Nebula binaries
  download_and_extract_nebula

  # Create CA certificate if it does not exist
  if [ ! -f ca.crt ]; then
    printf "Creating Certificate Authority...\n"
    nebula-cert ca -name "Myorganization, Inc"
  fi

  # Run appropriate setup function
  case $option in
    1)
      setup_lighthouse
      ;;
    2)
      setup_host
      ;;
    *)
      printf "Invalid option. Please run the script again and choose a valid option.\n"
      ;;
  esac
}

main "$@"

