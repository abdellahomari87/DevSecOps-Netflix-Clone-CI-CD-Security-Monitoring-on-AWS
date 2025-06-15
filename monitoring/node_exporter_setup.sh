#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_node_exporter_docker.sh
# Purpose     : Install Node Exporter using Docker (DevOps monitoring setup)
# Author      : Abdellah OMARI
# -----------------------------------------------------------------------------

echo "➡️  Installing Docker (if not already installed)..."
sudo apt update -y
sudo apt install -y docker.io curl

echo "✅ Docker installed. Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "🗑️  Removing existing Node Exporter container if any..."
if [ "$(sudo docker ps -aq -f name=node_exporter)" ]; then
  sudo docker rm -f node_exporter
fi

echo "🐳 Pulling the official Node Exporter Docker image..."
sudo docker pull prom/node-exporter

echo "🚀 Running Node Exporter container on port 9100..."
sudo docker run -d \
  --name node_exporter \
  --restart unless-stopped \
  -p 9100:9100 \
  prom/node-exporter

echo "⏳ Waiting for Node Exporter to be reachable on port 9100..."
for i in {1..30}; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:9100/metrics | grep -q "200"; then
    echo "✅ Node Exporter is up and running!"
    echo "🌐 Access metrics at: http://<your-EC2-public-IP>:9100/metrics"
    break
  else
    echo "⌛ Still waiting ($i/30)…"
    sleep 1
  fi
done
