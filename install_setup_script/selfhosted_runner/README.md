# 🚀 Self-Hosted GitHub Actions Runner in Kubernetes with ARC

This guide provides step-by-step instructions for installing Actions Runner Controller (ARC) in a Kubernetes cluster and deploying a self-hosted runner with a ConfigMap for insecure Docker registry settings.


# ✅ Prerequisites

- 🏗 A running Kubernetes cluster (local or cloud)
- 🔧 Helm installed (helm version)
- 🔑 GitHub PAT (Personal Access Token) with repo and admin:repo_hook permissions
- 🏠 Harbor registry running locally in Kubernetes

- 🐳 Docker configured to allow insecure registry communication


## 🔹 Step 1: Install Actions Runner Controller (ARC)

Add the Helm repository and install ARC:
```sh
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller

helm repo update
```

### 📦 Install ARC in Kubernetes

```sh
helm upgrade --install --namespace actions-runner-system --create-namespace \
  actions-runner-controller actions-runner-controller/actions-runner-controller
```

## 🔹 Step 2: Create GitHub Secret for ARC

Replace ``<GITHUB_ACCESS_TOKEN>`` with your GitHub PAT:

```sh
kubectl create secret generic controller-manager \
  --namespace actions-runner-system \
  --from-literal=github_token=<GITHUB_ACCESS_TOKEN>
```

## 🔹 Step 3: Configure Docker for Insecure Harbor Registry

### 📝 Create a ConfigMap for Docker Daemon Configuration
Replace harbor-registry.harbor.svc.cluster.local:5000 with your Harbor registry endpoint.

```sh
kubectl create configmap docker-insecure-config --namespace actions-runner-system \
  --from-literal=daemon.json='{
    "insecure-registries": ["harbor-registry.harbor.svc.cluster.local:5000"]
  }'
```

## 🔹 Step 4: Deploy a Self-Hosted Runner in Kubernetes

This deployment will:

✅ Use the ConfigMap to configure Docker

✅ Mount the host Docker socket for registry access

✅ Automatically restart Docker with insecure registry settings

### 📜 RunnerDeployment YAML
Save the following as runner-deployment.yaml:
```yml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: custom-runner
  namespace: actions-runner-system
spec:
  replicas: 1
  template:
    spec:
      repository: mihir-hadavani-inventyv/k8s-yml
      labels:
        - custom-runner
      containers:
        - name: runner
          image: summerwind/actions-runner:latest
          securityContext:
            privileged: true
          volumeMounts:
            - name: docker-config
              mountPath: /etc/docker/daemon.json
              subPath: daemon.json
      volumes:
        - name: docker-config
          configMap:
            name: docker-insecure-config
```

Apply the runner deployment:

```sh 
kubectl apply -f runner-deployment.yaml
```