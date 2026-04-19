#!/bin/bash
set -e

# Use the IP of the private network interface
NODE_IP=$(ip addr show eth1 | grep "inet " | awk '{print $2}' | cut -d/ -f1)

echo "Installing K3s Master on $NODE_IP..."

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=${NODE_IP} \
  --flannel-iface=eth1 \
  --write-kubeconfig-mode 644 \
  --token=${K3S_TOKEN} \
  --disable traefik \
  --node-taint CriticalAddonsOnly=true:NoExecute" sh -

# Wait for kubeconfig to be generated
sleep 10

# Prepare kubeconfig for host access (optional, but good for automation)
cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig/k3s.yaml
sed -i "s/127.0.0.1/${NODE_IP}/g" /vagrant/kubeconfig/k3s.yaml

echo "K3s Master installed successfully."
