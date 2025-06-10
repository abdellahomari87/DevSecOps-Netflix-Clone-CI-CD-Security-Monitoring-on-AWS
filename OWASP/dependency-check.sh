# Become root or use sudo in each command
sudo mkdir -p /opt/owasp
cd /opt/owasp

# Install unzip if it's not installed
sudo apt update && sudo apt install -y unzip

# Download the Dependency Check tool
sudo wget https://github.com/jeremylong/DependencyCheck/releases/download/v9.1.0/dependency-check-9.1.0-release.zip

# Unzip the package
sudo unzip dependency-check-9.1.0-release.zip

# Create the symlink
sudo ln -s /opt/owasp/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check