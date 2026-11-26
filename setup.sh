#!/usr/bin/env bash

set -euo pipefail
sudo apt-get update
sudo apt-get install -y curl nano tmux podman 
sudo apt install podman-compose

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh

echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
sudo tailscale set --advertise-exit-node

# pi-hole
echo 'net.ipv4.ip_unprivileged_port_start=53' | sudo tee /etc/sysctl.d/99-podman-ports.conf
sudo sysctl --system
podman compose -f ./pihole.yaml up -d

