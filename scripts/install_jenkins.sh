#!/bin/bash

# Update the system
sudo apt update -y

# Install required packages including Java 17
sudo apt install fontconfig openjdk-17-jdk -y

# Jenkins repository setup
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add the Jenkins repository to APT sources
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update packages and install Jenkins
sudo apt update
sudo apt install jenkins -y

# Enable and start the Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Allow Jenkins port through the firewall
sudo ufw allow 8080