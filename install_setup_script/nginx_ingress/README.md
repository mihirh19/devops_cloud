# 🚀 Ingress-NGINX Installation Script

This script automates the installation of the NGINX Ingress Controller in a Kubernetes cluster using Helm. It ensures that:  

✅ The `ingress-nginx` namespace exists.  
✅ The `ingress-nginx` Helm release is installed.  
✅ An external IP is assigned to the Ingress service.  

---

## 📜 Prerequisites

Before running the script, ensure you have the following installed:  

- [Kubernetes (kubectl)](https://kubernetes.io/docs/tasks/tools/)  
- [Helm](https://helm.sh/docs/intro/install/)  
- A running Kubernetes cluster with a LoadBalancer (e.g., MetalLB or a cloud provider).  

---

## 📥 Installation Steps

1️⃣ **Download the script**  

```sh
curl -o install-ingress.sh https://raw.githubusercontent.com/mihirh19/devops_cloud/refs/heads/main/install_setup_script/metallb/installnginxingress.sh
chmod +x install-ingress.sh
```