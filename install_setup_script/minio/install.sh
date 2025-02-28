#!/bin/bash

# 🚀 Set variables
MINIO_NAMESPACE="minio-dev"
MINIO_POD=$(kubectl get pods -n $MINIO_NAMESPACE -l app=minio --no-headers --output=name)
INGRESS_AVAILABLE=$(kubectl get ingress -n $MINIO_NAMESPACE --no-headers 2>/dev/null | wc -l)
HOSTPATH_DIR="/home/$USER/volume/minio"

# 🗂️ Create hostPath directory if not exists
if [ ! -d "$HOSTPATH_DIR" ]; then
    echo "📂 Creating directory: $HOSTPATH_DIR"
    mkdir -p "$HOSTPATH_DIR"
    chmod 777 "$HOSTPATH_DIR"
else
    echo "✅ Directory already exists: $HOSTPATH_DIR"
fi

# 🔍 Check if MinIO is already running
if [ -n "$MINIO_POD" ]; then
    echo "⚠️ MinIO is already running in namespace $MINIO_NAMESPACE."
    exit 1
fi

# 🌐 Check if Ingress is available
if [ "$INGRESS_AVAILABLE" -eq 0 ]; then
    echo "❌ No Ingress found in namespace $MINIO_NAMESPACE. Please configure Ingress before proceeding."
    exit 1
else
    echo "✅ Ingress is available."
fi

# 🛠️ Apply MinIO YAML
echo "🚀 Deploying MinIO..."
kubectl apply -f minio.yml

# 🎉 Done
echo "🎯 MinIO deployment initiated successfully!"
