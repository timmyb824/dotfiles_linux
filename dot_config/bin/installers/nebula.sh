#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

# Function to download and extract Nebula binaries
download_and_extract_nebula() {
  printf "Downloading Nebula...\n"
  curl -LOq https://github.com/slackhq/nebula/releases/download/v1.9.3/nebula-linux-amd64.tar.gz
  tar -xzf nebula-linux-amd64.tar.gz
  sudo mv nebula /usr/local/bin/
  sudo mv nebula-cert /usr/local/bin/
  rm nebula-linux-amd64.tar.gz
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
  sudo mkdir -p /etc/nebula

  # Download and configure example config
  curl -oq /tmp/config-lighthouse.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i 's/# am_lighthouse: false/am_lighthouse: true/' /tmp/config-lighthouse.yaml
  sed -i "s/#static_host_map:/static_host_map:\n  '$lh_ip': ['$lh_routable_ip:4242']/" /tmp/config-lighthouse.yaml
  sed -i '/inbound:/a \  inbound:\n    - port: any\n      proto: any\n      host: any' /tmp/config.yaml


  # Move certificates and config to config directory
  sudo mv ca.crt /etc/nebula/
  sudo mv "$lh_name".crt /etc/nebula/host.crt
  sudo mv "$lh_name".key /etc/nebula/host.key
  sudo mv /tmp/config-lighthouse.yaml /etc/nebula/config.yaml

  if command_exists zellij; then
    printf "Starting Nebula with Zellij...\n"
    zellij -s nebula -c "sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml"
  elif command_exists screen; then
    printf "Starting Nebula with Screen...\n"
    screen -dmS nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  elif command_exists tmux; then
    printf "Starting Nebula with Tmux...\n"
    tmux new-session -d -s nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  else
    printf "Starting Nebula...\n"
    sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  fi

  # Start Nebula
  # sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
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
  sudo mkdir -p /etc/nebula

  # Download and configure example config
  curl -oq /tmp/config.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i "s/#static_host_map:/static_host_map:\n  '192.168.100.1': ['$lh_routable_ip:4242']/" /tmp/config.yaml
  sed -i 's/# am_lighthouse: false/am_lighthouse: false/' /tmp/config.yaml
  sed -i "s/# hosts:/hosts:\n    - '192.168.100.1'/" /tmp/config.yaml
  sed -i '/inbound:/a \  inbound:\n    - port: any\n      proto: any\n      host: any' /tmp/config.yaml

  # Move certificates and config to config directory
  sudo mv ca.crt /etc/nebula/
  sudo mv "$host_name".crt /etc/nebula/host.crt
  sudo mv "$host_name".key /etc/nebula/host.key
  sudo mv /tmp/config.yaml /etc/nebula/config.yaml

  if command_exists zellij; then
    printf "Starting Nebula with Zellij...\n"
    zellij -s nebula -c "sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml"
  elif command_exists screen; then
    printf "Starting Nebula with Screen...\n"
    screen -dmS nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  elif command_exists tmux; then
    printf "Starting Nebula with Tmux...\n"
    tmux new-session -d -s nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  else
    printf "Starting Nebula...\n"
    sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  fi

  # # Start Nebula
  # sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
}

# Main script logic
main() {
  printf "Nebula Overlay Network Setup Script\n"
  printf "===================================\n"
  printf "1. Setup Lighthouse\n"
  printf "2. Setup Host\n"
  read -r -p "Choose an option (1 or 2): " option

  # Download and extract Nebula binaries
  download_and_extract_nebula

  # Create CA certificate if it does not exist
  if [ ! -f ca.key ]; then
    printf "Creating Certificate Authority...\n"
    nebula-cert ca -name "BryantHomelab"
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

