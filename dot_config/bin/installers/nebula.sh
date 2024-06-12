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

  create_lighthouse_config

  sudo mv /tmp/config.yaml /etc/nebula/config.yaml
  sudo mv "$lh_name".crt /etc/nebula/host.crt
  sudo mv "$lh_name".key /etc/nebula/host.key
  sudo mv ca.crt /etc/nebula/
  sudo mv ca.key /etc/nebula/

  create_systemd_service_file
  create_nebula_user
  start_nebula_service
}

setup_host() {
  echo "Setting up Host..."
  read -p "Enter the name for the Host (e.g., server): " host_name
  read -p "Enter the IP address for the Host (e.g., 192.168.100.9/24): " host_ip
  read -p "Enter the routable IP address for the Lighthouse: " lh_routable_ip

  nebula-cert sign -name "$host_name" -ip "$host_ip"
  sudo mkdir -p /etc/nebula

  create_host_config

  sudo mv /tmp/config.yaml /etc/nebula/config.yaml
  sudo mv "$host_name".crt /etc/nebula/host.crt
  sudo mv "$host_name".key /etc/nebula/host.key
  sudo mv ca.crt /etc/nebula/
  mv ca.key "$HOME"

  create_systemd_service_file
  create_nebula_user
  start_nebula_service
}

create_lighthouse_config() {
  echo_with_color "$GREEN_COLOR" "Creating Lighthouse config file..."
  sudo tee /etc/nebula/config.yaml >/dev/null <<EOL
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/$lh_name.crt
  key: /etc/nebula/$lh_name.key

static_host_map:

lighthouse:
  am_lighthouse: true

listen:
  host: 0.0.0.0
  port: 4242

punchy:
  punch: true

logging:
  level: info
  format: text

firewall:
  conntrack:
    tcp_timeout: 12m
    udp_timeout: 3m
    default_timeout: 10m

  outbound:
    - port: any
      proto: any
      host: any

  inbound:
    - port: any
      proto: any
      host: any
EOL
}

create_host_config() {
  echo_with_color "$GREEN_COLOR" "Creating Host config file..."
  sudo tee /etc/nebula/config.yaml >/dev/null <<EOL
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/$lh_name.crt
  key: /etc/nebula/$lh_name.key

static_host_map:
  $lh_ip: [$lh_routable_ip:4242]

lighthouse:
  am_lighthouse: false
  interval: 60
  hosts:
    - $lh_ip

listen:
  host: 0.0.0.0
  port: 4242

punchy:
  punch: true

logging:
  level: info
  format: text

firewall:
  conntrack:
    tcp_timeout: 12m
    udp_timeout: 3m
    default_timeout: 10m

  outbound:
    - port: any
      proto: any
      host: any

  inbound:
    - port: any
      proto: any
      host: any
EOL
}

create_systemd_service_file() {
    echo_with_color "$GREEN_COLOR" "Creating Nebula systemd service file..."
    sudo tee /etc/systemd/system/nebula.service >/dev/null <<EOL
# Systemd unit file for Nebula
#

[Unit]
Description=Nebula
Wants=basic.target
After=basic.target network.target
Before=sshd.service

[Service]
ExecStartPre=/usr/local/bin/nebula -test -config /etc/nebula/config.yaml
ExecStart=/usr/local/bin/nebula -config /etc/nebula/config.yaml
ExecReload=/bin/kill -HUP $MAINPID

RuntimeDirectory=nebula
ConfigurationDirectory=nebula
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
ProtectControlGroups=true
ProtectHome=true
ProtectKernelTunables=true
ProtectSystem=full
User=nebula
Group=neubla

SyslogIdentifier=nebula

Restart=always
RestartSec=2
TimeoutStopSec=5
StartLimitInterval=0
LimitNOFILE=131072

Nice=-1

[Install]
WantedBy=multi-user.target
EOL
}

create_nebula_user() {
  echo_with_color "$GREEN_COLOR" "Creating Nebula user..."
  sudo useradd -r -s /bin/false nebula
}

start_nebula_service() {
    echo_with_color "$GREEN_COLOR" "Starting nebula service..."
    sudo systemctl daemon-reload || exit_with_error "Failed to reload systemd daemon."
    sudo systemctl enable --now nebula || exit_with_error "Failed to enable and start nebula service."
    sudo systemctl status --no-pager nebula || exit_with_error "Failed to check nebula service status."
    echo_with_color "$GREEN_COLOR" "nebula service started successfully."
}

main() {
  if ! command_exists curl; then
    exit_with_error "curl is required to download Nebula. Please install curl and run the script again."
  fi

  echo "Nebula Overlay Network Setup Script"
  echo "==================================="
  echo "1. Setup Lighthouse"
  echo "2. Setup Host"
  read -r -p "Choose an option (1 or 2): " option

  download_and_extract_nebula

  if [ ! -f "$HOME/ca.key" ]; then
    echo_with_color "$GREEN_COLOR" "Creating Certificate Authority..."
    nebula-cert ca -name "BryantHomelab"
  fi

  case $option in
    1) setup_lighthouse ;;
    2) setup_host ;;
    *) echo "Invalid option. Please run the script again and choose a valid option." ;;
  esac
}

main "$@"