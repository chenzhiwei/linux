FROM docker.io/kindest/node:v1.25.2

RUN apt update \
    && apt -y install --no-install-recommends vim telnet iputils-ping iproute2 \
    && rm -rf /var/lib/apt/lists/*

COPY config.toml /etc/containerd/config.toml
