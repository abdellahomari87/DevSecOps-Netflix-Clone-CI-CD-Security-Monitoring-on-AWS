#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Installe un noeud WORKER Kubernetes avec containerd (K8s v1.33.1 – juin 2025)
# Auteur : Abdellah OMARI
# -----------------------------------------------------------------------------
set -euo pipefail

echo "📦 1) Mise à jour système et packages requis…"
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

echo "🐳 2) Installation de containerd (CRI pour Kubernetes)…"
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
# Utilisation de systemd comme driver cgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd && sudo systemctl enable containerd

echo "🔧 3) Activation modules noyau & IP forwarding…"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

echo "🔑 4) Ajout du dépôt Kubernetes (v1.33)…"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
 | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
 https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" \
 | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "📥 5) Installation de kubelet, kubeadm, kubectl (v1.33.1)…"
sudo apt-get update -y
K8S_VERSION=1.33.1-1.1
sudo apt-get install -y kubelet=${K8S_VERSION} kubeadm=${K8S_VERSION} kubectl=${K8S_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl

echo "🚫 6) Désactivation du swap (requis pour kubelet)…"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "✅ Prêt à rejoindre le cluster avec la commande 'kubeadm join' !"
