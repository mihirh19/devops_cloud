#!/bin/zsh

NAMESPACE="metallb-system"
RELEASE_NAME="metallb"
POOL_NAME="default-pool"
ADV_NAME="default-pool-advertisement"

echo "🚀 Starting MetalLB setup..."

# Step 1: Add MetalLB Helm repo
echo "📦 Adding MetalLB Helm repository..."
helm repo add metallb https://metallb.github.io/metallb
helm repo update
echo "✅ Helm repository updated!"

# Step 2: Create namespace if not exists
if ! kubectl get namespace $NAMESPACE &>/dev/null; then
    echo "🛠️ Creating namespace '$NAMESPACE'..."
    kubectl create namespace $NAMESPACE
else
    echo "✅ Namespace '$NAMESPACE' already exists!"
fi

# Step 3: Install MetalLB using Helm if not already installed
if ! helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
    echo "🚀 Installing MetalLB..."
    helm install $RELEASE_NAME metallb/metallb -n $NAMESPACE
    echo "✅ MetalLB installed successfully!"
else
    echo "✅ MetalLB is already installed! Skipping installation."
fi

# Step 4: Check if IPAddressPool exists
echo "🔍 Checking if IPAddressPool '$POOL_NAME' exists..."
kubectl get ipaddresspool -n $NAMESPACE | grep -q $POOL_NAME
if [ $? -eq 0 ]; then
    echo "✅ IPAddressPool '$POOL_NAME' already exists! Skipping creation."
else
    echo "🔧 Creating IPAddressPool '$POOL_NAME'..."
    cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: $POOL_NAME
  namespace: $NAMESPACE
spec:
  addresses:
  - 192.168.230.128/27
EOF
    echo "✅ IPAddressPool created!"
fi

# Step 5: Check if L2Advertisement exists
echo "🔍 Checking if L2Advertisement '$ADV_NAME' exists..."
kubectl get l2advertisement -n $NAMESPACE | grep -q $ADV_NAME
if [ $? -eq 0 ]; then
    echo "✅ L2Advertisement '$ADV_NAME' already exists! Skipping creation."
else
    echo "📢 Creating L2Advertisement '$ADV_NAME'..."
    cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: $ADV_NAME
  namespace: $NAMESPACE
spec:
  ipAddressPools:
  - $POOL_NAME
EOF
    echo "✅ L2Advertisement created!"
fi

echo "🎉 MetalLB setup and configuration complete!"
