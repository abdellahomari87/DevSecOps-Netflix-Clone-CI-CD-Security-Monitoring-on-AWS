#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_k8s_master.sh
# Purpose     : Install Kubernetes master node with containerd and Calico CNI
# Author      : Abdellah OMARI
# -----------------------------------------------------------------------------

echo "➡️  Updating system and installing required packages..."
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

echo "🐳 Installing containerd..."
sudo apt install -y containerd

echo "🔧 Enabling IP forwarding..."
sudo modprobe overlay
sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

echo "🔑 Adding Kubernetes APT repository key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "📦 Adding Kubernetes APT repository..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "🔄 Updating APT and installing kubelet, kubeadm, kubectl..."
sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "✅ Kubernetes tools and container runtime installed."

echo "🚀 Initializing Kubernetes master node..."
INIT_OUTPUT=$(sudo kubeadm init --pod-network-cidr=192.168.0.0/16)
echo "$INIT_OUTPUT"

# 🔐 Extraire la commande de join
echo "$INIT_OUTPUT" | grep -A 2 "kubeadm join" > $HOME/join-command.txt
echo "💾 Saved kubeadm join command to $HOME/join-command.txt"

echo "📁 Configuring kubectl access..."
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "🌐 Deploying Calico CNI (Container Network Interface)..."
sleep 30
kubectl apply --validate=false -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml

echo "✅ Kubernetes master node is fully initialized with Calico network plugin."
echo "📎 kubeadm join command saved in: $HOME/join-command.txt"
echo "🔗 You can now join worker nodes using the saved command."
