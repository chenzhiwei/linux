# Podman

Podman is a Docker alternative tool and which gets rid of the big daemon.

I like this tool, the commands are almost same as Docker.

## Build Podman Binaries

Build all the Podman required binaries inside container.

```
apt install --no-install-recommends docker.io
docker run --rm -v $(pwd):/data docker.io/library/ubuntu:22.04 /data/build-podman.sh
apt purge docker.io containerd runc
rm -rf /var/lib/docker

rsync -a files/* /
```

## Install Podman Runtime Dependencies

```
apt install fuse-overlayfs passt iptables
```

## Use wasm with Podman

### Rebuild crun with wasmedge runtime

Install wasmedge, you will get the header files, then build crun to enable wasmedge runtime:

```
git clone https://github.com/containers/crun
cd crun
./autogen.sh
./configure --with-wasmedge
make
cp crun /usr/bin/crun-wasm

crun-wasm -v
crun version 1.14.4
commit: a220ca661ce078f2c37b38c92e66cf66c012d9c1
rundir: /run/user/1000/crun
spec: 1.0.0
+SYSTEMD +SELINUX +APPARMOR +CAP +SECCOMP +EBPF +CRIU +WASM:wasmedge +YAJL
```

### Build a wasm image and run it

```
// main.go
package main

import "fmt"

func main() {
	fmt.Println("Hello, WebAssembly!")
}
```

```
// Dockerfile
FROM scratch

COPY main.wasm /
CMD ["/main.wasm"]
```

```
GOOS=wasip1 GOARCH=wasm go build -o main.wasm main.go
podman build --platform=wasi/wasm -t docker.io/siji/wasm-hello:latest .

podman run --rm docker.io/siji/wasm-hello:latest
```

## Build Multi-arch image

```
podman manifest create docker.io/siji/any:latest
podman build --platform linux/amd64,linux/arm64 --manifest docker.io/siji/any:latest .
podman manifest push docker.io/siji/any:latest
```

## Setup Mirrors

* prefix, the prefix of user-specified image name, can be omitted and default to `location`
* location, the physical location of the image
* insecure, pull image from HTTP or untrusted HTTPS
* block, pull image with matching name is forbidden

```
# docker.io/repo/image =>
     1. registry.dockermirror.com/repo/image
     2. mirror.com/repo/image
[[registry]]
block = false
location = "docker.io"

[[registry.mirror]]
location = "registry.dockermirror.com"

[[registry.mirror]]
insecure = true
location = "mirror.com"
```

```
# docker.io/repo/image => mirror.local/docker.io/repo/image
[[registry]]
location = "docker.io"

[[registry.mirror]]
insecure = true
location = "mirror.local/docker.io"
```

```
# Not recommend to set prefix
# docker.io/repo/image =>
     1. mirror.com/repo/image
     2. registry.dockermirror.com/repo/image
[[registry]]
prefix = "docker.io"
location = "registry.dockermirror.com"

[[registry.mirror]]
insecure = true
location = "mirror.com"
```

<details>
  <summary>Deprecated Steps</summary>

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

NOTE: The pre-built binary has issues.

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

### Build Skopeo

```
git clone https://github.com/containers/skopeo
cd skopeo
make bin/skopeo

cp bin/skopeo /usr/bin/
skopeo completion bash > /usr/share/bash-completion/completions/skopeo
```

### Install Helpers

```
CRUN_VERSION=$(curl -sSL https://api.github.com/repos/containers/crun/releases/latest | jq -r .tag_name)
curl -Lo /usr/bin/crun https://github.com/containers/crun/releases/download/${CRUN_VERSION}/crun-${CRUN_VERSION}-linux-amd64
chmod 755 /usr/bin/crun

curl -Lo /usr/libexec/podman/netavark.gz https://github.com/containers/netavark/releases/latest/download/netavark.gz
gunzip /usr/libexec/podman/netavark.gz

curl -Lo /usr/libexec/podman/aardvark-dns.gz https://github.com/containers/aardvark-dns/releases/latest/download/aardvark-dns.gz
gunzip /usr/libexec/podman/aardvark-dns.gz

curl -Lo /usr/libexec/podman/catatonit https://github.com/openSUSE/catatonit/releases/latest/download/catatonit.x86_64

chmod 755 /usr/libexec/podman/*
```

### Create Configuration files

* /etc/containers/policy.json
* /etc/containers/containers.conf
* /etc/containers/registries.conf

### On WSL2

由于 WSL2 内核不支持 nftables，因此需要将 iptables 设置为 legacy 模式。

```
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
```

### Rootless Podman

```
apt install fuse-overlayfs passt uidmap

vim ~/.config/containers/storage.conf
[storage]
  driver = "overlay"

[storage.options]
  mount_program = "/usr/bin/fuse-overlayfs"
```
</details>
