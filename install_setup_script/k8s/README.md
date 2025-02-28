# Kubernetes Setup Guide 🚀

This guide provides step-by-step instructions to install and set up a Kubernetes cluster using two scripts:
- `install_k8s.sh`: Installs containerd and Kubernetes components.
- `init_k8s.sh`: Initializes the cluster and configures Calico networking.

It also includes instructions for joining worker nodes and enabling scheduling on the master node.

---

## 1️⃣ Install Kubernetes and container runtime
Run the following script to install Kubernetes components and containerd:

```sh
chmod +x install_k8s.sh
sudo ./install_k8s.sh
```

This script will:
   - Install necessary dependencies.

   - Configure containerd as the container runtime.

   - Add and configure Kubernetes repositories.

   - Install kubelet, kubeadm, and kubectl.
   
## 2️⃣ Initialize the Kubernetes cluster

Run the following script to initialize the cluster:
```sh
chmod +x init_k8s.sh
sudo ./init_k8s.sh
```
This script will:

- Initialize the Kubernetes cluster with kubeadm.

- Set up the kubectl configuration for the user.
- Deploy the Calico network plugin.

## 3️⃣ Join Worker Nodes 🏗️


After initializing the master node, run the following command on worker nodes to join the cluster:

```sh
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> \
    --discovery-token-ca-cert-hash sha256:<HASH>
```
📌 Note: To get the join command, run this on the master node:
```sh
kubeadm token create --print-join-command
```
Run the output command on each worker node.


## 4️⃣ Allow Scheduling on the Master Node 🛠️

By default, scheduling on the master node is restricted. To allow scheduling, run:
```sh
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## 🎉 Verify Cluster Setup

```sh
kubectl get nodes
```
   