# Kubernetes

## Download kubectl

```
curl -LO https://dl.k8s.io/release/v1.25.0/bin/linux/amd64/kubectl

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

## Download helm

```
https://github.com/helm/helm/releases

curl -LO https://get.helm.sh/helm-v3.10.0-linux-amd64.tar.gz
```

## Download kubeadm

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/kubeadm

curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/linux/amd64/{kubeadm,kubelet,kubectl}
```
