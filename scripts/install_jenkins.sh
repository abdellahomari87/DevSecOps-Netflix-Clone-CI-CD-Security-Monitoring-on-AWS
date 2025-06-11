#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_jenkins_docker.sh
# Purpose     : Install Jenkins using Docker with persistent volume
# OS Support  : Ubuntu (tested on EC2 Ubuntu 20.04+ / 24.04+)
# Author      : Me 😊
# -----------------------------------------------------------------------------

echo "➡️  Updating the system and installing dependencies..."
sudo apt update -y
sudo apt install -y docker.io curl

echo "✅ Docker installed. Enabling and starting the Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adding the current user ($USER) to the docker group (will be active next login)..."
sudo usermod -aG docker $USER

echo "📦 Creating a Docker volume for persistent Jenkins data..."
sudo docker volume create jenkins_data

echo "🐳 Pulling and running the Jenkins container on ports 8080 and 50000..."
sudo docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  jenkins/jenkins:lts

echo "⏳ Waiting for Jenkins to initialize (up to 2 minutes)..."
for i in {1..24}; do
  if sudo docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword; then
    break
  fi
  echo "⌛ Jenkins is still starting... (${i}/24)"
  sleep 5
done

echo "🔐 Retrieving the initial Jenkins admin password:"
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "✅ Jenkins is up and running!"
echo "🌐 Access it at: http://<your-EC2-public-IP>:8080"
echo "🔑 Use the above password to unlock Jenkins via the web interface."
