#!/bin/zsh

echo "🚀 Starting the Kubernetes and container runtime setup..."

# Update system 🔄
sudo apt-get update

# Install required packages 📦
sudo apt-get install -y apt-transport-https curl

# Create directory for GPG keys if not exists 🔑
sudo mkdir -p /etc/apt/keyrings

# Install Docker repository GPG key and repo 🐳
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    echo "🔑 Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
else
    echo "✅ Docker GPG key already exists."
fi

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "📜 Adding Docker repository..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
    echo "✅ Docker repository already exists."
fi

# Update repositories 🔄
sudo apt-get update

# Install containerd if not installed 🛠️
if command -v containerd &> /dev/null; then
    echo "✅ containerd is already installed."
else
    echo "📦 Installing containerd..."
    sudo apt-get install -y containerd.io
fi

# Configure containerd ⚙️
echo "🛠️ Configuring containerd..."
sudo mkdir -p /etc/containerd
if [ ! -f /etc/containerd/config.toml ]; then
    sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
fi
sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install Kubernetes repository GPG key and repo 🚜
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
    echo "🔑 Adding Kubernetes GPG key..."
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
else
    echo "✅ Kubernetes GPG key already exists."
fi

if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
    echo "📜 Adding Kubernetes repository..."
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
else
    echo "✅ Kubernetes repository already exists."
fi

# Update repositories 🔄
sudo apt-get update

# Install kubelet, kubeadm, kubectl if not installed 🚀
for pkg in kubelet kubeadm kubectl; do
    if dpkg -l | grep -q $pkg; then
        echo "✅ $pkg is already installed."
    else
        echo "📦 Installing $pkg..."
        sudo apt-get install -y $pkg
    fi
done

# Hold Kubernetes packages to prevent automatic updates ⏳
sudo apt-mark hold kubelet kubeadm kubectl

# Enable and start kubelet ✅
echo "⚡ Enabling and starting kubelet..."
sudo systemctl enable --now kubelet

# Disable swap 🚫
echo "🚫 Disabling swap..."
sudo swapoff -a

# Enable necessary kernel modules 🖧
echo "⚙️ Enabling kernel modules..."
sudo modprobe br_netfilter
sudo sysctl -w net.ipv4.ip_forward=1

echo "🎉 Installation and configuration completed successfully! 🚀🎯"
