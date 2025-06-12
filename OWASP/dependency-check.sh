#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name : secure_dependency_check.sh
# Purpose     : Install and run OWASP Dependency-Check with NVD API Key (v8.4.0)
# Compatibility: Ubuntu 20.04+/24.04+ | Docker | EC2
# -----------------------------------------------------------------------------

set -e

echo "🔐 Please enter your NVD API Key (input hidden):"
read -s NVD_API_KEY

echo "📦 Step 1: Install Docker if not already present..."
sudo apt update -y
sudo apt install -y docker.io

echo "👥 Step 2: Add current user to Docker group..."
sudo usermod -aG docker "$USER"

echo "🔄 Step 3: Reload shell with Docker group permissions..."
# Launch new shell with updated group, and continue inside
sg docker <<EOF
echo "✅ Docker group loaded."

echo "📁 Step 4: Creating scan workspace..."
WORKDIR="\$HOME/dependency-check-project"
mkdir -p "\$WORKDIR"
cd "\$WORKDIR"

echo "⬇️ Step 5: Pulling OWASP Dependency-Check v8.4.0 image..."
docker pull owasp/dependency-check:8.4.0

echo "🚀 Step 6: Running the scan..."
docker run --rm \
  -e NVD_API_KEY="$NVD_API_KEY" \
  -v "\$WORKDIR:/src" \
  owasp/dependency-check:8.4.0 \
  --scan /src \
  --format HTML \
  --out /src/dependency-check-report

echo "✅ DONE! Your report is here:"
echo "📄 \$WORKDIR/dependency-check-report/dependency-check-report.html"
EOF
