# Kubernetes

## Install Kubernetes

### Environments

* CentOS 7.0 x86_64
* Kubernetes 0.5.6
* Etcd 0.4.6
* Docker 1.2.0
* Open vSwitch 2.1.2

Kubernetes Servers:

| **Role**    | **Hostname** | Interface | IP Address     |
|:------------|:-------------|:----------|:---------------|
| Kube Master | kube-master  | eth0      | 192.168.122.20 |
| Kube Minion | kube-minion1 | eth0      | 192.168.122.21 |
| Kube Minion | kube-minion2 | eth0      | 192.168.122.22 |
| Kube Minion | kube-minion3 | eth0      | 192.168.122.23 |

### Turn off firewall on all nodes

```
# systemctl stop firewalld.service iptables.service
# systemctl disable firewalld.service iptables.service
```

### Enable related yum repositories on all nodes

* CentOS 7 Base Repo

```
# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```

If you are using `rhel 7.0`, you can simply replace `$releasever` by `7` in `/etc/yum.repos.d/CentOS-Base.repo`.

### Create new users

On Kubernetes master node, create `kube` and `etcd` users:

```
# groupadd -r kube
# useradd -r -g kube -d / -s /sbin/nologin -c "Kubernetes user" kube
# groupadd -r etcd
# useradd -r -g etcd -m -d /var/lib/etcd -s /sbin/nologin -c "etcd user" etcd
```

On all Kubernetes minion nodes, create `kube` user:

```
# groupadd -r kube
# useradd -r -g kube -d / -s /sbin/nologin -c "Kubernetes user" kube
```

### Install and configure Etcd

On Kubernetes master node, do following steps:

* Install golang package

```
# yum -y install go
```

* Download and extract etcd package:

```
# cd /root/
# wget https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz
# tar xf etcd-v0.4.6-linux-amd64.tar.gz
```

* Change the owner and group to `root`:

```
# chown root:root etcd-v0.4.6-linux-amd64/etcd*
```

* Copy etcd bin files to `/usr/bin` directory:

```
# cp etcd-v0.4.6-linux-amd64/etcd* /usr/bin
```

* create configure file `/etc/etcd/etcd.conf` with content below:

```
# no content for now
```

* Create file `/usr/lib/systemd/system/etcd.service` with content below:

```
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
# etc logs to the journal directly, suppress double logging
StandardOutput=null
WorkingDirectory=/var/lib/etcd
User=etcd
ExecStart=/usr/bin/etcd

[Install]
WantedBy=multi-user.target
```

* Start etcd service

```
# systemctl daemon-reload
# systemctl start etcd.service
# systemctl enable etcd.service
```

### Install and configure Kubernetes on master node

On Kubernetes master node, do following steps:

* Download and extract Kubernetes package:

```
# cd /root
# wget https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v0.5.4/kubernetes.tar.gz
# tar xf kubernetes.tar.gz
# tar xf kubernetes/server/kubernetes-server-linux-amd64.tar.gz
```

* Change the owner and group to `root`:

```
# chown root:root kubernetes/server/bin/kube*
```

* Copy Kubernetes bin files to `/usr/bin` directory:

```
# cp kubernetes/server/bin/kube* /usr/bin
```

* create configure file `/etc/kubernetes/apiserver` with content below:

```
KUBE_API_ADDRESS="--address=0.0.0.0"
KUBE_API_PORT="--port=8080"
KUBE_MASTER="--master=192.168.122.20:8080"
KUBELET_PORT="--kubelet_port=10250"
KUBE_SERVICE_ADDRESSES="--portal_net=10.254.0.0/16"
KUBE_API_ARGS=""
```

* create configure file `/etc/kubernetes/config` with content below:

```
KUBE_ETCD_SERVERS="--etcd_servers=http://192.168.122.20:4001"
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow_privileged=false"
```

* create configure file `/etc/kubernetes/controller-manager` with content below:

```
KUBELET_ADDRESSES="--machines=192.168.122.21,192.168.122.22,192.168.122.23"
KUBE_CONTROLLER_MANAGER_ARGS=""
```

* create configure file `/etc/kubernetes/scheduler` with content below:

```
KUBE_SCHEDULER_ARGS=""
```

* Create file `/usr/lib/systemd/system/kube-apiserver.service` with content below:

```
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
User=kube
ExecStart=/usr/bin/kube-apiserver \
        ${KUBE_LOGTOSTDERR} \
        ${KUBE_LOG_LEVEL} \
        ${KUBE_ETCD_SERVERS} \
        ${KUBE_API_ADDRESS} \
        ${KUBE_API_PORT} \
        ${KUBELET_PORT} \
        ${KUBE_ALLOW_PRIV} \
        ${KUBE_SERVICE_ADDRESSES} \
        ${KUBE_API_ARGS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

* Create file `/usr/lib/systemd/system/kube-controller-manager.service` with content below:

```
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
EnvironmentFile=-/etc/kubernetes/controller-manager
User=kube
ExecStart=/usr/bin/kube-controller-manager \
        ${KUBE_LOGTOSTDERR} \
        ${KUBE_LOG_LEVEL} \
        ${KUBELET_ADDRESSES} \
        ${KUBE_MASTER} \
        ${KUBE_CONTROLLER_MANAGER_ARGS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

* Create file `/usr/lib/systemd/system/kube-scheduler.service` with content below:

```
[Unit]
Description=Kubernetes Scheduler Plugin
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
EnvironmentFile=-/etc/kubernetes/scheduler
User=kube
ExecStart=/usr/bin/kube-scheduler \
        ${KUBE_LOGTOSTDERR} \
        ${KUBE_LOG_LEVEL} \
        ${KUBE_MASTER} \
        ${KUBE_SCHEDULER_ARGS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

* Start Kuberletes services

```
# systemctl daemon-reload
# systemctl start kube-apiserver.service kube-controller-manager.service kube-scheduler.service
# systemctl enable kube-apiserver.service kube-controller-manager.service kube-scheduler.service
```

### Install and configure openvswitch on minion nodes

On all Kubernetes minion nodes, do following steps:

* Install and start openvswitch

```
# cd /root
# wget https://repos.fedorapeople.org/repos/openstack/openstack-juno/epel-7/openvswitch-2.1.2-2.el7.centos.1.x86_64.rpm
# yum -y localinstall openvswitch-2.1.2-2.el7.centos.1.x86_64.rpm
# systemctl start openvswitch.service
# systemctl enable openvswitch.service
```

* Create OVS bridge `obr0`

```
# ovs-vsctl add-br obr0
```

* Create OVS GRE tunnel

On `192.168.122.21`, run:

```
# ovs-vsctl add-port obr0 gre2 -- set Interface gre2 type=gre options:remote_ip=192.168.122.22
# ovs-vsctl add-port obr0 gre3 -- set Interface gre3 type=gre options:remote_ip=192.168.122.23
```

On `192.168.122.22`, run:

```
# ovs-vsctl add-port obr0 gre1 -- set Interface gre1 type=gre options:remote_ip=192.168.122.21
# ovs-vsctl add-port obr0 gre3 -- set Interface gre3 type=gre options:remote_ip=192.168.122.23
```

On `192.168.122.23`, run:

```
# ovs-vsctl add-port obr0 gre1 -- set Interface gre1 type=gre options:remote_ip=192.168.122.21
# ovs-vsctl add-port obr0 gre2 -- set Interface gre2 type=gre options:remote_ip=192.168.122.22
```

* Create Kubernetes bridge and make interface `obr0` a port of bridge `kbr0`

```
# brctl addbr kbr0
# brctl addif kbr0 obr0
```

* Create interface file of bridge `kbr0`

On `192.168.122.21`, create interface file `/etc/sysconfig/network-scripts/ifcfg-kbr0` with content:

```
DEVICE=kbr0
ONBOOT=yes
BOOTPROTO=static
IPADDR=172.17.1.1
NETMASK=255.255.255.0
USERCTL=no
TYPE=Bridge
IPV6INIT=no
```

On `192.168.122.22`, create interface file `/etc/sysconfig/network-scripts/ifcfg-kbr0` with content:

```
DEVICE=kbr0
ONBOOT=yes
BOOTPROTO=static
IPADDR=172.17.2.1
NETMASK=255.255.255.0
USERCTL=no
TYPE=Bridge
IPV6INIT=no
```

On `192.168.122.23`, create interface file `/etc/sysconfig/network-scripts/ifcfg-kbr0` with content:

```
DEVICE=kbr0
ONBOOT=yes
BOOTPROTO=static
IPADDR=172.17.3.1
NETMASK=255.255.255.0
USERCTL=no
TYPE=Bridge
IPV6INIT=no
```

* Make the `kbr0` up

```
# ifdown kbr0
# ifup kbr0
```

* Create the router file for kbr0

On `192.168.122.21`, create router file `/etc/sysconfig/network-scripts/route-eth0` with content:

```
172.17.2.0/24 via 192.168.122.22
172.17.3.0/24 via 192.168.122.23
```

On `192.168.122.22`, create router file `/etc/sysconfig/network-scripts/route-eth0` with content:

```
172.17.1.0/24 via 192.168.122.21
172.17.3.0/24 via 192.168.122.23
```

On `192.168.122.23`, create router file `/etc/sysconfig/network-scripts/route-eth0` with content:

```
172.17.1.0/24 via 192.168.122.21
172.17.2.0/24 via 192.168.122.22
```

* Apply the route for `kbr0`

```
# ifup eth0
```

* Install and configure Docker

```
# yum -y install go docker
# sed -i 's/^OPTIONS=.*$/OPTIONS=--selinux-enabled -b kbr0/g' /etc/sysconfig/docker
# systemctl start docker.service
# systemctl enable docker.service
```

### Install and configure Kubernetes on minion nodes

On all Kubernetes minion node, do following steps:

* Download and extract Kubernetes package:

```
# cd /root
# wget https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v0.5.4/kubernetes.tar.gz
# tar xf kubernetes.tar.gz
# tar xf kubernetes/server/kubernetes-server-linux-amd64.tar.gz
```

* Change the owner and group to `root`:

```
# chown root:root kubernetes/server/bin/kube*
```

* Copy Kubernetes bin files to `/usr/bin` directory:

```
# cp kubernetes/server/bin/kube* /usr/bin
```

* create configure file `/etc/kubernetes/config` with content below:

```
KUBE_ETCD_SERVERS="--etcd_servers=http://192.168.122.20:4001"
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow_privileged=false"
```

* create configure file `/etc/kubernetes/kubelet` with content below:

Update the `--hostname_override=192.168.122.21` to your minion nodes' IP address.

```
KUBELET_ADDRESS="--address=0.0.0.0"
KUBELET_PORT="--port=10250"
KUBELET_HOSTNAME="--hostname_override=192.168.122.21"
KUBELET_ARGS=""
```

* create configure file `/etc/kubernetes/proxy` with content below:

```
KUBE_PROXY_ARGS=""
```

* Create file `/usr/lib/systemd/system/kubelet.service` with content below:

```
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.socket cadvisor.service
Requires=docker.socket

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/kubelet
ExecStart=/usr/bin/kubelet \
        ${KUBE_LOGTOSTDERR} \
        ${KUBE_LOG_LEVEL} \
        ${KUBE_ETCD_SERVERS} \
        ${KUBELET_ADDRESS} \
        ${KUBELET_PORT} \
        ${KUBELET_HOSTNAME} \
        ${KUBE_ALLOW_PRIV} \
        ${KUBELET_ARGS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

* Create file `/usr/lib/systemd/system/kube-proxy.service` with content below:

```
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/proxy
ExecStart=/usr/bin/kube-proxy \
        ${KUBE_LOGTOSTDERR} \
        ${KUBE_LOG_LEVEL} \
        ${KUBE_ETCD_SERVERS} \
        ${KUBE_PROXY_ARGS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

* Start Kuberletes services

```
# systemctl daemon-reload
# systemctl enable kubelet.service kube-proxy.service
# systemctl start kubelet.service kube-proxy.service
```

### Reference

* Kubernetes: <https://github.com/GoogleCloudPlatform/kubernetes>
* Practical Kubernetes Deployment: <http://www.infoq.com/cn/articles/centos7-practical-kubernetes-deployment>
* Open vSwitch and GRE tunneling: <http://www.fredski.nl/multi-node-single-nic-network-using-open-vswitch-and-gre-tunneling/>
* Getting started on Fedora: <https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/getting-started-guides/fedora/fedora_manual_config.md>

## Using Kubernetes

On Kubernetes master node:

```
# cd /root/kubernetes/examples/guestbook
# kubecfg -h http://192.168.122.20:8080 list minions
# kubecfg list minions
Minion identifier
----------
192.168.122.21
192.168.122.22
192.168.122.23
```

```
# kubecfg -c redis-master.json create pods
# kubecfg -c redis-master-service.json create services
# kubecfg list pods
Name                Image(s)            Host                Labels                   Status
----------          ----------          ----------          ----------               ----------
redis-master        dockerfile/redis    192.168.122.21/     name=redis-master        Running

# kubecfg list services
Name                Labels              Selector                                  IP                  Port
----------          ----------          ----------                                ----------          ----------
kubernetes                              component=apiserver,provider=kubernetes   10.254.150.81       443
kubernetes-ro                           component=apiserver,provider=kubernetes   10.254.181.110      80
redis-master        name=redis-master   name=redis-master                         10.254.83.131       6379

# kubecfg list events
Name                Kind                Status              Reason              Message
----------          ----------          ----------          ----------          ----------
redis-master        Pod                 Pending             scheduled           Successfully assigned redis-master to 192.168.122.21
```
