#!/bin/zsh

echo "🚀 Initializing Kubernetes cluster..."

# Check if Kubernetes is already initialized
if kubectl get nodes &> /dev/null; then
    echo "✅ Kubernetes cluster is already initialized!"
    exit 0
fi

# Initialize Kubernetes with Calico pod network 🚜
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Configure kubectl for the current user 🏗️
echo "⚙️ Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply Calico network plugin 🌐
echo "🌐 Deploying Calico network plugin..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "🎉 Kubernetes cluster setup completed! 🚀"
