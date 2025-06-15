#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_docker.sh
# Purpose     : Install Docker on Ubuntu and allow current user to run Docker without sudo
# Author      : Abdellah OMARI
# -----------------------------------------------------------------------------

echo "➡️ Updating system..."
sudo apt update -y

echo "🐳 Installing Docker and curl..."
sudo apt install -y docker.io curl

echo "✅ Docker installed. Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER

echo "✅ Docker installation completed!"
echo "🔁 Applying group changes using 'newgrp'..."

# Recharge le groupe sans déconnexion
newgrp docker <<EONG
echo "✅ Docker group applied without re-login. You can now use 'docker' without sudo."
exec bash
EONG
