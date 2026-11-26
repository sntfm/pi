#!/usr/bin/env bash

set -euo pipefail
sudo apt-get update
sudo apt-get install -y nano tmux podman curl

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh

echo 'net.ipv4.ip_forward = 1' | sudo tee /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
sudo tailscale set --advertise-exit-node

