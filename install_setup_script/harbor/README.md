# 📜 Harbor Installation Guide
This guide will help you install Harbor on your Kubernetes cluster using Helm. It also ensures that Harbor is not already installed before proceeding.


## 📌 Prerequisites
Before you begin, ensure you have the following installed:

- 🐳 Kubernetes cluster
- 🔧 Helm package manager

- 📦 kubectl CLI tool

## 🔍 Step 1: Check if Harbor is Already Installed

Before installing, check if Harbor is already installed:
```sh
helm list -n harbor
```

## 🛠 Step 2: Add the Harbor Helm Repository
```sh
helm repo add harbor https://helm.goharbor.io
helm repo update
```

## 📂 Step 3: Create the Namespace (If Not Exists)

```sh
kubectl create namespace harbor --dry-run=client -o yaml | kubectl apply -f -
```

## 💾 Step 4: Apply Persistent Volume Configuration
Ensure you have a ``harborpv.yml`` file and apply it:
```sh
kubectl apply -f harborpv.yml
```

```yml
# harborpv.yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-registry
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/mihir/volume/registry
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - mihir
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-registry
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-jobservice
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/mihir/volume/jobservice
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - mihir

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-jobservice
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-database
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/mihir/volume/database
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - mihir

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-database
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-redis
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /home/mihir/volume/redis
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - mihir

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-redis
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard


---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-pv-trivy
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard

  hostPath:
    path: /home/mihir/volume/trivy
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - mihir
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: harbor-pvc-trivy
  namespace: harbor
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
```


change path and hostname in pv where you have to create pv

## ⚙️ Step 5: Install Harbor Using Helm

```sh
helm install harbor harbor/harbor -n harbor -f values.yaml
```

```yml
# values.yml

expose:
  type: ingress
  tls:
  
    enabled: false
   
    certSource: auto
    auto:
     
      commonName: ""
    secret:
     
      secretName: ""
  ingress:
    hosts:
      core: mihir.harbor.com
   
    controller: default
  
    kubeVersionOverride: ""
    className: "nginx"
    annotations:
    
      ingress.kubernetes.io/ssl-redirect: "false"
#      nginx.ingress.kubernetes.io/rewrite-target: /
      ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
#      nginx.ingress.kubernetes.io/backend-protocol: s
    labels: {}
  clusterIP:
    # The name of ClusterIP service
    name: harbor
    # The ip address of the ClusterIP service (leave empty for acquiring dynamic ip)
    staticClusterIP: ""
    ports:
      # The service port Harbor listens on when serving HTTP
      httpPort: 80
      # The service port Harbor listens on when serving HTTPS
      httpsPort: 443
    # Annotations on the ClusterIP service
    annotations: {}
    # ClusterIP-specific labels
    labels: {}
  nodePort:
    # The name of NodePort service
    name: harbor
    ports:
      http:
        # The service port Harbor listens on when serving HTTP
        port: 80
        # The node port Harbor listens on when serving HTTP
        nodePort: 30002
      https:
        # The service port Harbor listens on when serving HTTPS
        port: 443
        # The node port Harbor listens on when serving HTTPS
        nodePort: 30003
    # Annotations on the nodePort service
    annotations: {}
    # nodePort-specific labels
    labels: {}
  loadBalancer:
    # The name of LoadBalancer service
    name: harbor
    # Set the IP if the LoadBalancer supports assigning IP
    IP: ""
    ports:
      # The service port Harbor listens on when serving HTTP
      httpPort: 80
      # The service port Harbor listens on when serving HTTPS
      httpsPort: 443
    # Annotations on the loadBalancer service
    annotations: {}
    # loadBalancer-specific labels
    labels: {}
    sourceRanges: []

externalURL: http://mihir.harbor.com


persistence:
  enabled: true
  
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
     
      existingClaim: "harbor-pvc-registry"
     
      storageClass: "standard"
      subPath: ""
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}
    jobservice:
      jobLog:
        existingClaim: "harbor-pvc-jobservice"
        storageClass: "standard"
        subPath: ""
        accessMode: ReadWriteOnce
        size: 1Gi
        annotations: {}

    database:
      existingClaim: "harbor-pvc-database"
      storageClass: "standard"
      subPath: ""
      accessMode: ReadWriteOnce
      size: 1Gi
      annotations: {}

    redis:
      existingClaim: "harbor-pvc-redis"
      storageClass: "standard"
      subPath: ""
      accessMode: ReadWriteOnce
      size: 1Gi
      annotations: {}
    trivy:
      existingClaim: "harbor-pvc-trivy"
      storageClass: "standard"
      subPath: ""
      accessMode: ReadWriteOnce
      size: 5Gi
      annotations: {}

  imageChartStorage:

    disableredirect: false

    type: filesystem
    filesystem:
      rootdirectory: /storage
      #maxthreads: 100
    azure:
      accountname: accountname
      accountkey: base64encodedaccountkey
      container: containername
 
```

## change this file not override 

## 🔧 Configure Insecure Registry for Docker and Containerd

### 🐳 Step 9: Configure Docker

#### Edit the Docker Daemon config file:

```sh
sudo nano /etc/docker/daemon.json
```

```json
{
    "insecure-registries": ["mihir.harbor.com"]
}
```
#### Now restart Docker:

```sh
sudo systemctl restart docker
```

### 📦 Step 10: Configure Containerd

#### Edit the Containerd config file:

```sh
sudo nano /etc/containerd/config.toml
```

#### Find the section [plugins."io.containerd.grpc.v1.cri".registry.mirrors] and add:

```toml
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."mihir.harbor.com"]
    endpoint = ["http://mihir.harbor.com"]

```

#### Restart Containerd:
```sh
sudo systemctl restart containerd
```
