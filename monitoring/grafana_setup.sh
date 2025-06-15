#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_grafana_docker.sh
# Purpose     : Install Grafana using Docker with persistent volume
# Author      : Abdellah OMARI
# -----------------------------------------------------------------------------

echo "➡️  Updating system & installing Docker..."
sudo apt update -y
sudo apt install -y docker.io curl

echo "✅ Docker installed. Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adding current user to the docker group (effective after logout/login)..."
sudo usermod -aG docker $USER

echo "📦 Creating Docker volume for Grafana..."
sudo docker volume create grafana_data

echo "🗑️  Removing existing Grafana container if any..."
if [ "$(sudo docker ps -aq -f name=grafana)" ]; then
  sudo docker rm -f grafana
fi

echo "🐳 Pulling the official Grafana Docker image..."
sudo docker pull grafana/grafana-oss

echo "🚀 Running Grafana container on port 3000..."
sudo docker run -d \
  --name grafana \
  --restart unless-stopped \
  -p 3000:3000 \
  -v grafana_data:/var/lib/grafana \
  grafana/grafana-oss

echo "⏳ Waiting for Grafana to be reachable on port 3000..."
for i in {1..30}; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
    echo "✅ Grafana is up!"
    break
  fi
  echo "⌛ Still waiting ($i/30)…"
  sleep 5
done

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "🌐 Access Grafana at: http://$PUBLIC_IP:3000"
echo "🔑 Default credentials → Login: admin | Password: admin"
echo "✅ Installation completed! Keeping the SSH session alive."
echo "🛑 Press Ctrl+C to exit."
exec /bin/bash
