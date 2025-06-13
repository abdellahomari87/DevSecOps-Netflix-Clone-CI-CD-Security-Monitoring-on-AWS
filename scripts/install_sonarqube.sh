#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_sonarqube_docker.sh
# Purpose     : Install SonarQube using Docker with persistent volumes
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

echo "📦 Creating Docker volumes for SonarQube..."
sudo docker volume create sonarqube_data
sudo docker volume create sonarqube_extensions
sudo docker volume create sonarqube_logs

echo "🐳 Pulling the official SonarQube Docker image..."
sudo docker pull sonarqube:lts-community

echo "🚀 Running SonarQube container on port 9000..."
sudo docker run -d \
  --name sonarqube \
  --restart unless-stopped \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:lts-community

echo "⏳ Waiting for SonarQube to be reachable on port 9000..."

for i in {1..30}; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 | grep -q "200"; then
    echo "✅ SonarQube is up!"
    echo "🌐 Access it at: http://<your-EC2-public-IP>:9000"
    echo "🔑 Default credentials → Login: admin | Password: admin"
    exit 0
  fi
  echo "⌛ Still waiting ($i/30)..."
  sleep 5
done

echo "❌ SonarQube did not start in expected time. Check logs with:"
echo "   sudo docker logs -f sonarqube"
exit 1
echo "🟢 SonarQube is running. Press Ctrl+C to exit but SonarQube will keep running in the background."
tail -f /dev/null
