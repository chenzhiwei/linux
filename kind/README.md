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

Using local private registry as mirror of all other registries.

copy the file to host `/etc/containerd/certs.d/_default/hosts.toml`

Append following to `/etc/containerd/config.toml`.

```
version = 2

[plugins."io.containerd.grpc.v1.cri".registry]
   config_path = "/etc/containerd/certs.d"
```
