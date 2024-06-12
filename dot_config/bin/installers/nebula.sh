#!/usr/bin/env bash

source "$(dirname "$BASH_SOURCE")/../init/init.sh"

download_and_extract_nebula() {
  echo_with_color "$GREEN_COLOR" "Downloading Nebula..."
  curl -sLO https://github.com/slackhq/nebula/releases/download/v1.9.3/nebula-linux-amd64.tar.gz
  tar -xzf nebula-linux-amd64.tar.gz -C /tmp
  sudo mv /tmp/nebula /usr/local/bin/
  sudo mv /tmp/nebula-cert /usr/local/bin/
  rm nebula-linux-amd64.tar.gz
}

setup_lighthouse() {
  echo_with_color "$GREEN_COLOR" "Setting up Lighthouse..."
  read -r -p "Enter the name for the Lighthouse (e.g., lighthouse1): " lh_name
  read -r -p "Enter the IP address for the Lighthouse (e.g., 192.168.100.1/24): " lh_ip
  read -r -p "Enter the routable IP address for the Lighthouse: " lh_routable_ip

  nebula-cert sign -name "$lh_name" -ip "$lh_ip"
  sudo mkdir -p /etc/nebula

  curl -s -o /tmp/config.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i 's/# am_lighthouse: false/am_lighthouse: true/' /tmp/config.yaml
  sed -i "s/#static_host_map:/static_host_map:\n  '$lh_ip': ['$lh_routable_ip:4242']/" /tmp/config.yaml
  sed -i '/inbound:/a \  inbound:\n    - port: any\n      proto: any\n      host: any' /tmp/config.yaml

  sudo mv /tmp/config.yaml /etc/nebula/config.yaml
  sudo mv "$lh_name".crt /etc/nebula/host.crt
  sudo mv "$lh_name".key /etc/nebula/host.key
  sudo mv ca.crt /etc/nebula/

  if command_exists zellij; then
    echo_with_color "$GREEN_COLOR" "Starting Nebula with zellij..."
    zellij -s nebula -c "sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml"
  elif command_exists screen; then
    echo_with_color "$GREEN_COLOR" "Starting Nebula with screen..."
    screen -dmS nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  elif command_exists tmux; then
    echo_with_color "$GREEN_COLOR" "Starting Nebula with tmux..."
    tmux new-session -d -s nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  else
    echo_with_color "$GREEN_COLOR" "Starting Nebula..."
    sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  fi
}

setup_host() {
  echo "Setting up Host..."
  read -p "Enter the name for the Host (e.g., server): " host_name
  read -p "Enter the IP address for the Host (e.g., 192.168.100.9/24): " host_ip
  read -p "Enter the routable IP address for the Lighthouse: " lh_routable_ip

  nebula-cert sign -name "$host_name" -ip "$host_ip"
  sudo mkdir -p /etc/nebula

  curl -s -o /tmp/config.yaml https://raw.githubusercontent.com/slackhq/nebula/master/examples/config.yml
  sed -i "s/#static_host_map:/static_host_map:\n  '192.168.100.1': ['$lh_routable_ip:4242']/" /tmp/config.yaml
  sed -i 's/# am_lighthouse: false/am_lighthouse: false/' /tmp/config.yaml
  sed -i "s/# hosts:/hosts:\n    - '192.168.100.1'/" /tmp/config.yaml
  sed -i '/inbound:/a \  inbound:\n    - port: any\n      proto: any\n      host: any' /tmp/config.yaml

  sudo mv /tmp/config.yaml /etc/nebula/config.yaml
  sudo mv "$host_name".crt /etc/nebula/host.crt
  sudo mv "$host_name".key /etc/nebula/host.key
  sudo mv ca.crt /etc/nebula/

  if command_exists zellij; then
    echo_with_color "$GREEN_COLOR" "Starting Nebula with zellij..."
    zellij -s nebula -c "sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml"
  elif command_exists screen; then
    echo_with_color "$GREEN_COLOR" "Starting Nebula with screen..."
    screen -dmS nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  elif command_exists tmux; then
    echo_with_color "$GREEN_COLOR" "Starting Nebula with tmux..."
    tmux new-session -d -s nebula sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  else
    echo_with_color "$GREEN_COLOR" "Starting Nebula..."
    sudo /usr/local/bin/nebula -config /etc/nebula/config.yaml
  fi
}

main() {
  echo "Nebula Overlay Network Setup Script"
  echo "==================================="
  echo "1. Setup Lighthouse"
  echo "2. Setup Host"
  read -r -p "Choose an option (1 or 2): " option

  download_and_extract_nebula

  if [ ! -f "$HOME/ca.key" ]; then
    echo_with_color "$GREEN_COLOR" "Creating Certificate Authority..."
    nebula-cert ca -name "BryantHomelab"
    mv ca.key "$HOME"
  fi

  case $option in
    1) setup_lighthouse ;;
    2) setup_host ;;
    *) echo "Invalid option. Please run the script again and choose a valid option." ;;
  esac
}

main "$@"