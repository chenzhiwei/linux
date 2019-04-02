# Deploy Ceph Storage Cluster

Deploy a single all-in-one node for development.

## SSH password-less access

```
ssh-copy-id localhost
```

## Install ceph-deploy

```
apt install virtualenv
virtualenv -p python3 ceph-deploy
source ceph-deploy/bin/activate
pip install ceph-deploy
```

## Create a cluster

```
cd mycluster
ceph-deploy new --public-network 9.30.255.51/21 zhiwei-1
```

Add public network to ceph.conf file.


## Install Ceph package

```
ceph-deploy install zhiwei-1
```


## Deploy the initial monitor(s) and gather the keys

```
ceph-deploy mon create-initial
```


## Configure ceph client

```
ceph-deploy admin zhiwei-1
```


## Deploy a manager daemon

```
ceph-deploy mgr create zhiwei-1
```

## Add OSD

### Create fake block device as my machine has no extra device/vdb

```
dd if=/dev/zero of=/var/fake-bd bs=50M count=1000
losetup loop95 /var/fake-bd

pvcreate /dev/loop95
vgcreate ceph-vg /dev/loop95
lvcreate -l 512 -n ceph-lv ceph-vg
```

### Create OSD

```
ceph-deploy osd create --data  /dev/ceph-vg/ceph-lv zhiwei-1
```

### Create OSD pool and user

```
ceph osd pool create kube 8 8
ceph auth add client.kube mon 'allow r' osd 'allow rwx pool=kube'
```

### Get user key

```
ceph auth get client.admin
ceph auth get-key client.kube
```

## Extend the cluster

TBC

## Integrate with Kubernetes

### Create ceph-admin-secret

```
# used for adminId & adminSecretName
kubectl -n kube-system create secret generic ceph-admin-secret --type="kubernetes.io/rbd" --from-literal=key='AQBUDaNcfD9JIxAA60CdRGITnOSk78sbHqFwxg=='

# used for userId & userSecretName
kubectl -n kube-system create secret generic ceph-kube-secret --type="kubernetes.io/rbd" --from-literal=key='AQBUDaNcfD9JIxAA60CdRGITnOSk78fdsfrwevf=='
```

### Create ceph-rbd storage class

```
kubectl apply -f storage-class-ceph-rbd.yaml
```

### Create pvc & deployment

```
kubectl apply -f deployment-nginx.yaml
```

## Reference

1. http://docs.ceph.com/docs/mimic/start/quick-ceph-deploy/
2. https://kubernetes.io/docs/concepts/storage/storage-classes/
3. https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd
