# Zot Registry

## Start

```
podman run -d --name zot --network host \
    -v /etc/zot:/etc/zot \
    -v /var/lib/zot:/var/lib/zot \
    ghcr.io/project-zot/zot-linux-amd64:latest serve /etc/zot/config.yaml

podman run -d --name nginx --network host \
    -v /etc/nginx/conf.d:/etc/nginx/conf.d docker.io/library/nginx:latest
```
