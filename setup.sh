#!/usr/bin/env bash

set -euo pipefail
sudo apt-get update
sudo apt-get install -y curl nano tmux podman podman-compose netavark aardvark-dns

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
podman compose -f ./yaml/pihole.yaml up -d

# linkwarden
DIR=$HOME/linkwarden
SRC="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$DIR"
cp "$SRC/yaml/linkwarden.yaml" "$DIR/"
cd "$DIR"

# Create .env with random secrets on first run only
if [[ ! -f .env ]]; then
  IP=$(hostname -I | awk '{print $1}')
  cat > .env <<EOF
NEXTAUTH_URL=http://$IP:3000/api/v1/auth
NEXTAUTH_SECRET=$(openssl rand -hex 32)
POSTGRES_PASSWORD=$(openssl rand -hex 24)
MEILI_MASTER_KEY=$(openssl rand -hex 32)
EOF
  chmod 600 .env
fi

podman-compose -f linkwarden.yaml pull
podman-compose -f linkwarden.yaml up -d

echo "Linkwarden is starting at http://$(hostname -I | awk '{print $1}'):3000"
echo "Logs: cd $DIR && sudo podman-compose -f linkwarden.yaml logs -f"
