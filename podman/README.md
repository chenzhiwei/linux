# Podman

Podman is a Docker alternative tool and which gets rid of the big daemon.

I like this tool, the commands are almost same as Docker.

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
CRUN_VERSION=1.7.2
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
apt install fuse-overlayfs slirp4netns uidmap

vim ~/.config/containers/storage.conf
[storage]
  driver = "overlay"

[storage.options]
  mount_program = "/usr/bin/fuse-overlayfs"
```
