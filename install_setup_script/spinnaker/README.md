# 🚀 Spinnaker Installation & Google Cloud Pub/Sub Integration  

This guide covers the installation of **Spinnaker** in Kubernetes using **Halyard** and integrates it with **Google Cloud Pub/Sub** for event-driven deployments.  

---

## 📌 Prerequisites  
Before proceeding, ensure you have:  
✅ A running **Kubernetes cluster** (with `kubectl` access)  
✅ **NGINX Ingress & MetalLB** configured  
✅ **Google Cloud SDK (`gcloud`)** installed and authenticated  
✅ **Helm** installed  

---

# 🏗️ Step 1: Prepare the Host Machine  

### 🔹 1.1 Create Required Directories  
On your **Kubernetes node**, run:  

```sh
sudo mkdir -p /var/data/spinnaker/
```

### 🔹 1.2 Set Correct Permissions
Ensure proper ownership and access:
```sh
sudo chown -R 1000:1000 /var/data/spinnaker/
sudo chmod -R 755 /var/data/spinnaker/

sudo chown -R 1000:1000 /root/.kube/
sudo chmod -R 755 /root/.kube/

```

## 🔧 Step 2: Install Spinnaker Using Halyard
### 🔹 2.1 Deploy Halyard in Kubernetes

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    role: svc-halyard
  name: svc-infra-halyard
  namespace: default
spec:
  ipFamilies:
    - IPv4
  ports:
    - name: halyard
      port: 8084
      protocol: TCP
      targetPort: 8084
    - name: halyard-web
      port: 9000
      protocol: TCP
      targetPort: 9000
  selector:
    instance: pod-halyard
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    instance: pod-halyard
    role: pod-halyard
  name: pod-infra-halyard
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      instance: pod-halyard
      role: pod-halyard
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: 'false'
      labels:
        instance: pod-halyard
        role: pod-halyard
    spec:
      hostAliases:
      - ip: "192.168.230.128"
        hostnames:
        - "mihir.spinnaker.com"
        - "mihir.harbor.com"
        - "gate.mihir.spinnaker.com"
        - "mihir.minio.com"
      containers:
        - image: 'us-docker.pkg.dev/spinnaker-community/docker/halyard:stable'
          imagePullPolicy: IfNotPresent
          name: pod-halyard
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
          volumeMounts:
            - mountPath: /home/spinnaker/.hal
              name: hal-vol
            - mountPath: /home/spinnaker/.kube
              name: kube-vol
            - mountPath: /var/gcp
              name: gcp-acc
      initContainers:
        - command:
            - sh
            - '-c'
            - >-
              mkdir -p /home/spinnaker/.hal && chown -R 1000:1000
              /home/spinnaker/.hal && mkdir -p /var/gcp
          image: busybox
          imagePullPolicy: Always
          name: update-permission-crt
          volumeMounts:
            - mountPath: /opt/spin
              name: blank-vol
            - mountPath: /home/spinnaker/.hal
              name: hal-vol
      volumes:
        - hostPath:
            path: /var/data/spinnaker/
            type: ''
          name: hal-vol
        - emptyDir: {}
          name: blank-vol
        - hostPath:
            path: /root/.kube/
            type: '' 
          name: kube-vol
        - name: gcp-acc
          secret:
            secretName: gcp

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: spinnaker-ingress
  namespace: spinnaker
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: nginx
  rules:
  - host: mihir.spinnaker.com  # Change to your domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: spin-deck
            port:
              number: 9000

---


apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gate-spinnaker-ingress
  namespace: spinnaker
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: nginx
  rules:
  - host: gate.mihir.spinnaker.com  # Change to your domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: spin-gate
            port:
              number: 8084
```



Apply the deployment:

```sh
kubectl apply -f halyard-deployment.yaml
```

### 🔹 2.2 Install Spinnaker Using Halyard
Once the Halyard pod is running, execute:

```sh
kubectl exec -it pod-infra-halyard -- bash
```

Inside the pod, install Spinnaker:
```bash
hal config provider kubernetes enable

CONTEXT=$(kubectl config current-context)

hal config provider kubernetes account add my-k8s-account \
    --context $CONTEXT
    
hal config deploy edit --type distributed --account-name my-k8s-account


hal config storage s3 edit \
    --endpoint http://minio-service.minio-dev.svc.cluster.local:9000 \
    --access-key-id access-key \
    --secret-access-key secrect-key \
    --bucket spin \
    --region us-east-1 \
    --path-style-access true

hal config storage edit --type s3

hal version list

hal config version edit --version $VERSION

hal deploy apply

hal config security ui edit \
    --override-base-url "http://mihir.spinnaker.com"          # this is ingress

hal config security api edit \
    --override-base-url "http://gate.mihir.spinnaker.com"    # this is ingress

```

## 📡 Step 3: Configure Google Cloud Pub/Sub
### 🔹 3.1 Create Pub/Sub Topic & Subscription

```sh
export TOPIC="spinnaker-topic"
export SUBSCRIPTION="spinnaker-subscription"

gcloud beta pubsub topics create $TOPIC
gcloud beta pubsub subscriptions create $SUBSCRIPTION --topic $TOPIC

```

### 🔹 3.2 Create Google Cloud Service Account

```sh
export SERVICE_ACCOUNT_NAME="spinnaker-pubsub"

gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name "$SERVICE_ACCOUNT_NAME"

SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')

PROJECT=$(gcloud config get-value project)

gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL
```

### 🔹 3.3 Generate & Store Service Account Key

```sh
export SERVICE_ACCOUNT_DEST="$HOME/spinnaker-pubsub-key.json"
mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)

gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST \
    --iam-account $SA_EMAIL

```

## 🔑 Step 4: Inject Service Account Key into Kubernetes

### 🔹 4.1 Create a ConfigMap

```sh
kubectl create secret generic gcp \
    --from-file=$HOME/spinnaker-pubsub-key.json \
    -n default

```

### 🔹 4.2 Modify Halyard Deployment to Mount ConfigMap

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-infra-halyard
  namespace: default
spec:
  template:
    spec:
      containers:
        - name: pod-halyard
          volumeMounts:
            - mountPath: /var/gcp
              name: gcp-acc
              readOnly: true
      volumes:
        - name: gcp-acc
          secret:
            secretName: gcp
```

```sh
kubectl apply -f halyard-deployment.yaml
```

## ⚡ Step 5: Enable Pub/Sub in Spinnaker

-  go into halyad pod 
```sh
hal config pubsub google enable
hal config pubsub google subscription add spinnaker-pubsub \
    --subscription-name $SUBSCRIPTION \
    --json-path /var/gcp/service-account.json \
    --project $PROJECT \
    --message-format CUSTOM

hal deploy apply

```

## 🎉 Congratulations!
You have successfully set up Spinnaker with Google Cloud Pub/Sub in Kubernetes! 🚀
