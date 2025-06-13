#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : install_trivy_docker.sh
# Purpose     : Install Trivy via Docker and run a security scan with reports
# Author      : Abdellah OMARI
# -----------------------------------------------------------------------------

echo "➡️  Updating system & installing Docker..."
sudo apt update -y && sudo apt install -y docker.io curl

echo "✅ Docker installed. Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "📦 Creating Trivy cache volume..."
sudo docker volume create trivy-cache

echo "⬇️ Pulling Trivy Docker image..."
sudo docker pull aquasec/trivy

# Creating report directory
REPORT_DIR="$HOME/trivy-reports"
mkdir -p "$REPORT_DIR"

echo "🧪 Running scan on current directory and generating reports..."
sudo docker run --rm \
  -v "$PWD:/app" \
  -v trivy-cache:/root/.cache/ \
  -v "$REPORT_DIR:/reports" \
  aquasec/trivy fs /app \
  --format json \
  --output /reports/scan-report.json

sudo docker run --rm \
  -v "$PWD:/app" \
  -v trivy-cache:/root/.cache/ \
  -v "$REPORT_DIR:/reports" \
  aquasec/trivy fs /app \
  --format table > "$REPORT_DIR/scan-report.txt"

echo "📄 Reports saved in: $REPORT_DIR"
echo "✅ Trivy is fully operational!"
