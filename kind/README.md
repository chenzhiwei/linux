# Kind

## Create Cluster

```
kind create cluster --config kind.yaml
```

## Deploy NFS Server

```
podman run -d --name nfs-server --ip 10.88.111.111 --cap-add SYS_ADMIN -v /var/nfs:/var/nfs docker.io/siji/nfs-server:latest
```

## Deploy NFS CSI Driver

```
kubectl apply -f nfs-csi-driver/nfs-csi-rbac.yaml
kubectl apply -f nfs-csi-driver/nfs-csi-driverinfo.yaml
kubectl apply -f nfs-csi-driver/nfs-csi-controller.yaml
kubectl apply -f nfs-csi-driver/nfs-csi-node.yaml

kubectl -n nfs-csi get pod -o wide
```

## Deploy NFS CSI StorageClass

```
kubectl -n nfs-csi create secret generic mount-options --from-literal mountOptions="nfsvers=3,hard"
kubectl apply -f nfs-csi-driver/nfs-csi-storageclass.yaml
```

## Test NFS CSI Driver

```
kubectl apply -f nfs-provisioning/static-pvc.yaml
kubectl apply -f nfs-provisioning/static-pv.yaml
kubectl apply -f nfs-provisioning/static-deployment.yaml

kubectl apply -f nfs-provisioning/dynamic-pvc.yaml

kubectl apply -f nfs-provisioning/dynamic-statefulset.yaml

kubectl get pvc -o wide
kubectl get pod -o wide
```

## Setup CR Mirror

Run when you are in a private network that has no Internet access.

### Create Container Registry

```
podman run -d --name container-registry --ip 10.88.1.1 -v /var/lib/registry:/var/lib/registry docker.io/siji/registry:2
```

### Set Containerd Mirror

Append following to `/etc/containerd/config.toml`.

```
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.k8s.io"]
  endpoint = ["https://10.88.1.1", "https://registry.k8s.io",]

[plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
  endpoint = ["https://10.88.1.1", "https://registry-1.docker.io",]

[plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]
  endpoint = ["https://10.88.1.1", "https://quay.io",]

[plugins."io.containerd.grpc.v1.cri".registry.configs."10.88.1.1".tls]
  insecure_skip_verify = true
```
