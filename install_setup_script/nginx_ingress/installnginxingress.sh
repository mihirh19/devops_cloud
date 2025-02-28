#!/bin/zsh

echo "🚀 Checking if ingress-nginx is already installed..."

# Check if the namespace exists
if kubectl get namespace ingress-nginx &>/dev/null; then
    echo "✅ Namespace 'ingress-nginx' exists."
else
    echo "⚠️ Namespace 'ingress-nginx' not found. Creating..."
    kubectl create namespace ingress-nginx
fi

# Check if the Helm release exists
if helm list -n ingress-nginx | grep -q 'ingress-nginx'; then
    echo "✅ Ingress-NGINX is already installed."
else
    echo "📥 Installing Ingress-NGINX..."
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
fi

# Wait for external IP assignment
echo "⏳ Waiting for external IP..."
for i in {1..10}; do
    EXTERNAL_IP=$(kubectl get svc -n ingress-nginx -o jsonpath="{.items[?(@.metadata.name=='ingress-nginx-controller')].status.loadBalancer.ingress[0].ip}")
    if [[ -n "$EXTERNAL_IP" ]]; then
        echo "🌍 External IP assigned: $EXTERNAL_IP"
        break
    fi
    echo "⏳ Still waiting... ($i/10)"
    sleep 5
done

# Display service details
echo "🔍 Fetching Ingress-NGINX service details..."
kubectl get svc -n ingress-nginx

echo "✅ Setup complete!"
