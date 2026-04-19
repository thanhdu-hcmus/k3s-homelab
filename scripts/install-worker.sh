#!/bin/bash
set -e

# Use the IP of the private network interface
NODE_IP=$(ip addr show eth1 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
MASTER_IP="192.168.56.11"

echo "Installing K3s Worker on $NODE_IP, joining master at $MASTER_IP..."

curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" \
  INSTALL_K3S_EXEC="agent \
  --node-ip=${NODE_IP} \
  --flannel-iface=eth1" sh -

echo "K3s Worker installed and joined successfully."
