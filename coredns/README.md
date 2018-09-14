# CoreDNS

CoreDNS is a DNS flexible server.

## Binary

```
coredns -conf /etc/coredns/Corefile
```

## Docker image

```
docker run -d --net host --name coredns -v /etc/coredns:/etc/coredns coredns/coredns:1.2.2 -conf /etc/coredns/Corefile
```
