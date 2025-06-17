#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Installe Kubernetes v1.33 + containerd + Calico v3.30 (Ubuntu 22.04/24.04)
# Auteur : Abdellah OMARI – MAJ juin 2025
# -----------------------------------------------------------------------------
set -euo pipefail
echo "📦 1) Mise à jour de la machine…"
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

echo "🐳 2) Installation & configuration de containerd…"
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
# Utiliser systemd comme cgroup driver
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd && sudo systemctl enable containerd

echo "🔧 3) Activation des modules noyau & IP forwarding…"
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

echo "🔑 4) Dépôt officiel Kubernetes (v1.33)…"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
 | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
 https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" \
 | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "📥 5) Installation kubeadm/kubelet/kubectl 1.33.1…"
sudo apt-get update -y
K8S_VERSION=1.33.1-1.1
sudo apt-get install -y kubelet=${K8S_VERSION} kubeadm=${K8S_VERSION} kubectl=${K8S_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl

echo "🚀 6) Initialisation du control-plane…"
sudo swapoff -a                               # K8s ≠ swap
sudo kubeadm init \
  --kubernetes-version=v1.33.1 \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --pod-network-cidr=192.168.0.0/16 \
  --image-repository registry.k8s.io

echo "🔐 7) Configuration de kubectl pour l’utilisateur courant…"
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "🌐 8) Déploiement de Calico v3.30…"
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/calico.yaml

echo "✅  Kubernetes v1.33 + Calico v3.30 opérationnels."
echo "➕  La commande 'kubeadm join …' est affichée ci-dessus ; joins tes workers !"
