#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_docker.sh
# Purpose     : Install Docker and ensure user can use docker without sudo
# -----------------------------------------------------------------------------

echo "➡️  Updating system..."
sudo apt update -y

echo "🐳 Installing Docker and curl..."
sudo apt install -y docker.io curl

echo "✅ Docker installed. Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER

echo "✅ Docker installation completed!"

# 🔁 Inform the user to reconnect only if necessary
echo "🔁 Please log out and log in again (or restart your SSH session) to use 'docker' without sudo."

# ✅ Test immediately if new group is active
echo "🔍 Verifying docker access without sudo..."

if docker ps &>/dev/null; then
  echo "✅ You can already use Docker without sudo!"
else
  echo "⚠️  'docker' not yet usable without sudo. Using temporary workaround..."

  echo "💡 Running 'newgrp docker' to switch group in current session"
  newgrp docker <<EOF
    echo "✅ Inside newgrp docker shell. Testing Docker access..."
    docker ps
    echo "⚠️  You will need to exit this shell to return to normal."
EOF
fi
