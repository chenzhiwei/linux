# Podman

Podman is a Docker alternative tool and which gets rid of the big daemon.

I like this tool, the commands are almost same as Docker.

## Systemd

```
# /etc/systemd/system/podman-privoxy.service
[Unit]
Description=Privoxy in Podman Container
After=network.target

[Service]
Type=simple
TimeoutStartSec=30s
ExecStartPre=-/usr/bin/podman rm privoxy

ExecStart=/usr/bin/podman run --name privoxy --network host docker.io/siji/privoxy:3.0.24

ExecReload=-/usr/bin/podman stop privoxy
ExecReload=-/usr/bin/podman rm privoxy
ExecStop=-/usr/bin/podman stop privoxy
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

## Install

```
add-apt-repository -y ppa:projectatomic/ppa
apt install podman
```

## Kubernetes Pod

```
# /etc/systemd/system/pod@.service
[Unit]
Description=Podman Container
After=network.target

[Service]
Type=oneshot
TimeoutStartSec=30s
ExecStartPre=-/usr/bin/podman play kube /etc/podman/%i.yaml

ExecStart=/usr/bin/podman pod start %i

ExecStop=-/usr/bin/podman pod stop %i

RemainAfterExit=yes

[Install]
WantedBy=multi-user.target


# systemctl daemon-reload
```

```
mkdir -p /etc/podman
cp imap-app.yaml /etc/podman

systemctl enable pod@imap-app
```

```
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  containers:
  - command:
    - sleep
    - 100000
    image: docker.io/siji/nginx:latest
    name: app
    ports:
    - containerPort: 80
      hostPort: 80
```

## Build Podman

### Install Build Library

```
apt install \
  btrfs-progs \
  gcc \
  iptables \
  libassuan-dev \
  libbtrfs-dev \
  libc6-dev \
  libdevmapper-dev \
  libglib2.0-dev \
  libgpgme-dev \
  libgpg-error-dev \
  libprotobuf-dev \
  libprotobuf-c-dev \
  libseccomp-dev \
  libselinux1-dev \
  libsystemd-dev \
  make \
  pkg-config \
  uidmap
```

### Build conmon

```
git clone https://github.com/containers/conmon
cd conmon
make

mkdir -p /usr/libexec/podman
cp bin/conmon /usr/libexec/podman/
```

### Build podman

```
git clone https://github.com/containers/podman
cd podman
make BUILDTAGS="selinux seccomp systemd"

cp bin/podman /usr/bin/

podman completion bash > /usr/share/bash-completion/completions/podman
```

### Install crun/netavark

```
wget https://github.com/containers/crun/releases/download/1.4.4/crun-1.4.4-linux-amd64

chmod +x crun-*
mv crun-* /usr/bin/crun


wget https://github.com/containers/netavark/releases/download/v1.0.2/netavark.gz

gunzip netavark.gz
chmod +x netavark
mv netavark /usr/libexec/podman/

wget https://github.com/openSUSE/catatonit/releases/download/v0.1.7/catatonit.x86_64
chmod +x catatonit.x86_64
mv catatonit.x86_64 /usr/libexec/podman/catatonit
```

### Create policy.json

```
mkdir -p /etc/containers
vim /etc/containers/policy.json

{
  "default": [
    {
      "type": "insecureAcceptAnything"
    }
  ],
  "transports":{
    "docker-daemon": {
      "": [{"type":"insecureAcceptAnything"}]
    }
  }
}
```

### Create containers.conf

```
vim /etc/containers/containers.conf

[engine]
infra_image = "docker.io/siji/pause:3.7"
```

### Create registries.conf

```
echo 'unqualified-search-registries=["docker.io"]' > /etc/containers/registries.conf
```

### Build Skopeo

```
git clone https://github.com/containers/skopeo
cd skopeo
make bin/skopeo

cp bin/skopeo /usr/bin/
cp completions/bash/skopeo /usr/share/bash-completion/completions/
```
