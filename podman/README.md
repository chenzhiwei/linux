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
