# 🚀 MetalLB Setup Script  

This script automates the installation and configuration of **MetalLB** in a Kubernetes cluster using **Helm**. It ensures that MetalLB is installed and configured with an **IP address pool** and **L2 advertisement**.  

## 📜 Features  
✔ Adds the MetalLB Helm repository and updates it.  
✔ Creates the `metallb-system` namespace if it doesn't exist.  
✔ Installs MetalLB using Helm (if not already installed).  
✔ Configures an **IPAddressPool** (`192.168.230.128/27`).  
✔ Configures an **L2Advertisement** (ensures MetalLB can advertise IPs).  
✔ Skips setup if resources already exist.  

---

## 📌 Prerequisites  

Before running this script, ensure you have:  
- A running **Kubernetes cluster**.  
- **kubectl** installed and configured.  
- **Helm** installed.  

If you need Helm, install it using:  
```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# 🔧 Installation & Usage

## 1️⃣ Download the script
```sh
curl -O https://github.com/mihirh19/devops_cloud/install_setup_script/metallb/installmetallb.sh
```