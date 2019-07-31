# Podman

Podman is a Docker alternative tool and which gets rid of the big daemon.

I like this tool, the commands are almost same as Docker.

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
