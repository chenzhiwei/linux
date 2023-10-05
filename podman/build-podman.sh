#!/usr/bin/bash

set -eux -o pipefail

function prepare_dir() {
    mkdir -p etc/containers/{manifest,systemd} usr/bin usr/libexec/podman usr/lib/systemd/system-generators usr/share/bash-completion/completions/
}

function install_deps() {
    apt update
    apt install -y \
        binutils \
        btrfs-progs \
        curl \
        gcc \
        git \
        iptables \
        jq \
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
}

function install_golang() {
    GO_VERSION=$(curl -sSL https://go.dev/VERSION?m=text | head -1)
    curl -sSL -o /tmp/go.tgz https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
    tar xf /tmp/go.tgz -C /usr/local/
}

function build_conmon() {
    CONMON_VERSION=$(curl -sSL https://api.github.com/repos/containers/conmon/releases/latest | jq -r .tag_name)
    git clone --depth=1 -b $CONMON_VERSION https://github.com/containers/conmon /tmp/conmon
    cd /tmp/conmon
    make
    cd -
    cp /tmp/conmon/bin/conmon usr/libexec/podman/
}

function build_podman() {
    install_golang
    export PATH=$PATH:/usr/local/go/bin
    export GOROOT=/usr/local/go
    PODMAN_VERSION=$(curl -sSL https://api.github.com/repos/containers/podman/releases/latest | jq -r .tag_name)
    git clone --depth=1 -b $PODMAN_VERSION https://github.com/containers/podman /tmp/podman
    cd /tmp/podman
    make BUILDTAGS="selinux seccomp systemd" podman rootlessport quadlet
    cd -
    cp /tmp/podman/bin/podman usr/bin/
    cp /tmp/podman/bin/{rootlessport,quadlet} usr/libexec/podman/
    usr/bin/podman completion bash > usr/share/bash-completion/completions/podman
    cp ../etc/containers/{*.conf,*.json} etc/containers/
    cd usr/lib/systemd/system-generators/
    ln -s ../../../libexec/podman/quadlet podman-systemd-generator
    cd -
}

function build_skopeo() {
    SKOPEO_VERSION=$(curl -sSL https://api.github.com/repos/containers/skopeo/releases/latest | jq -r .tag_name)
    git clone --depth=1 -b $SKOPEO_VERSION https://github.com/containers/skopeo /tmp/skopeo
    cd /tmp/skopeo
    make bin/skopeo
    cd -
    cp /tmp/skopeo/bin/skopeo usr/bin/
    usr/bin/skopeo completion bash > usr/share/bash-completion/completions/skopeo
}

function fetch_binaries() {
    CRUN_VERSION=$(curl -sSL https://api.github.com/repos/containers/crun/releases/latest | jq -r .tag_name)
    curl -sSL -o usr/bin/crun https://github.com/containers/crun/releases/download/${CRUN_VERSION}/crun-${CRUN_VERSION}-linux-amd64

    curl -sSL -o usr/libexec/podman/netavark.gz https://github.com/containers/netavark/releases/latest/download/netavark.gz
    gunzip usr/libexec/podman/netavark.gz

    curl -sSL -o usr/libexec/podman/aardvark-dns.gz https://github.com/containers/aardvark-dns/releases/latest/download/aardvark-dns.gz
    gunzip usr/libexec/podman/aardvark-dns.gz
}

function strip_and_chmod() {
    chmod 755 usr/bin/* usr/libexec/podman/*
    strip usr/bin/* usr/libexec/podman/*
}

mkdir -p /data/files
cd /data/files

prepare_dir
install_deps
build_conmon
build_podman
build_skopeo
fetch_binaries
strip_and_chmod
