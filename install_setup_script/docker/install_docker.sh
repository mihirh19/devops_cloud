#!/bin/zsh

# 🚀 Function to check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null; then
        echo "✅ Docker is already installed! Version: $(docker --version)"
        exit 0
    else
        echo "⚠️ Docker is not installed. Proceeding with installation..."
    fi
}

# 🛠️ Function to install Docker
install_docker() {
    echo "🔍 Updating package lists..."
    sudo apt-get update -y

    echo "📦 Installing dependencies..."
    sudo apt-get install -y ca-certificates curl

    echo "🔑 Adding Docker’s official GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "📜 Setting up the Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo "🔄 Updating package index again..."
    sudo apt-get update -y

    echo "🐳 Installing Docker..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "⚙️ Enabling and starting Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker

    echo "🛠️ Verifying installation..."
    if docker --version; then
        echo "🎉 Docker installed successfully!"
    else
        echo "❌ Docker installation failed!"
    fi
}

# Run the script
check_docker
install_docker
