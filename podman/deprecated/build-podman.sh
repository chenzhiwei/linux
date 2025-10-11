#!/usr/bin/bash

set -eux -o pipefail

function prepare_dir() {
    mkdir -p usr/bin usr/libexec/podman \
             usr/local/{bin,lib} \
             usr/lib/systemd/system-generators \
             usr/share/bash-completion/completions
}

function install_deps() {
    apt update
    apt install -y \
        autoconf \
        automake \
        binutils \
        btrfs-progs \
        build-essential \
        curl \
        gcc \
        git \
        go-md2man \
        iptables \
        jq \
        libassuan-dev \
        libbtrfs-dev \
        libc6-dev \
        libcap-dev \
        libdevmapper-dev \
        libglib2.0-dev \
        libgpgme-dev \
        libgpg-error-dev \
        libprotobuf-dev \
        libprotobuf-c-dev \
        libseccomp-dev \
        libselinux1-dev \
        libsystemd-dev \
        libtool \
        libyajl-dev \
        make \
        pkg-config \
        python3 \
        uidmap
}

function install_golang() {
    GO_VERSION=$(curl -sSL https://golang.google.cn/VERSION?m=text | head -1)
    curl -sSL -o /tmp/go.tgz https://golang.google.cn/dl/${GO_VERSION}.linux-amd64.tar.gz
    tar xf /tmp/go.tgz -C /usr/local/
}

function build_conmon() {
    CONMON_VERSION=$(curl -sSL https://api.github.com/repos/containers/conmon/releases/latest | jq -r .tag_name)
    git clone --depth=1 -b $CONMON_VERSION https://github.com/containers/conmon /tmp/conmon
    cd /tmp/conmon
    make PREFIX=/usr
    cd -
    cp /tmp/conmon/bin/conmon usr/libexec/podman/
}

function build_crun() {
    # Install WasmEdge
    curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash -s -- -p /usr/local
    cp /usr/local/bin/wasmedge* usr/local/bin/
    cp -P /usr/local/lib/libwasmedge* usr/local/lib/

    CRUN_VERSION=$(curl -sSL https://api.github.com/repos/containers/crun/releases/latest | jq -r .tag_name)
    git clone --depth=1 -b $CRUN_VERSION https://github.com/containers/crun /tmp/crun
    cd /tmp/crun
    ./autogen.sh
    ./configure --with-wasmedge
    make PREFIX=/usr
    cd -
    cp /tmp/crun/crun usr/bin/crun
    cp /tmp/crun/crun usr/bin/crun-wasm
}

function build_podman() {
    install_golang
    export PATH=$PATH:/usr/local/go/bin
    export GOROOT=/usr/local/go
    PODMAN_VERSION=$(curl -sSL https://api.github.com/repos/containers/podman/releases/latest | jq -r .tag_name)
    git clone --depth=1 -b $PODMAN_VERSION https://github.com/containers/podman /tmp/podman
    cd /tmp/podman
    make PREFIX=/usr BUILDTAGS="selinux seccomp systemd exclude_graphdriver_devicemapper" podman rootlessport quadlet
    cd -
    cp /tmp/podman/bin/podman usr/bin/
    cp /tmp/podman/bin/{rootlessport,quadlet} usr/libexec/podman/
    usr/bin/podman completion bash > usr/share/bash-completion/completions/podman
    cp -r ../metadata/* .
    cd usr/lib/systemd/system-generators/
    ln -s ../../../libexec/podman/quadlet podman-systemd-generator
    cd -
}

function build_skopeo() {
    SKOPEO_VERSION=$(curl -sSL https://api.github.com/repos/containers/skopeo/releases/latest | jq -r .tag_name)
    git clone --depth=1 -b $SKOPEO_VERSION https://github.com/containers/skopeo /tmp/skopeo
    cd /tmp/skopeo
    make PREFIX=/usr bin/skopeo
    cd -
    cp /tmp/skopeo/bin/skopeo usr/bin/
    usr/bin/skopeo completion bash > usr/share/bash-completion/completions/skopeo
}

function fetch_binaries() {
    # CRUN_VERSION=$(curl -sSL https://api.github.com/repos/containers/crun/releases/latest | jq -r .tag_name)
    # curl -sSL -o usr/bin/crun https://github.com/containers/crun/releases/download/${CRUN_VERSION}/crun-${CRUN_VERSION}-linux-amd64

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
build_crun
build_podman
build_skopeo
fetch_binaries
strip_and_chmod
