# SkyDNS

SkyDNS is a distributed service for announcement and discovery of services built on top of etcd.

## 编译安装

```
$ go get github.com/skynetservices/skydns
$ cd $GOPATH/src/github.com/skynetservices/skydns
$ go build -v
```

## 启动使用

安装配置etcd请查看[etcd文档](../etcd/)。

### Linux amd64

```
# cd cd $GOPATH/bin
# ./skydns -domain="."
```

### Docker

```
# docker run -d -p 172.17.42.1:53:53/udp --name skydns skynetservices/skydns -domain="." -machines="http://172.17.42.1:4001" -addr="0.0.0.0:53" -nameservers="8.8.8.8:53,8.8.4.4:53"
```

## 设置一个域名

### abc.com 解析到 10.0.0.1

```
$ curl -X PUT http://172.17.42.1:4001/v2/keys/skydns/com/abc -d value='{"host": "10.0.0.1"}'
$ dig @127.0.0.1 abc.com
```

### xyz 解析到 10.0.0.2

```
$ curl -X PUT http://172.17.42.1:4001/v2/keys/skydns/xyz -d value='{"host": "10.0.0.2"}'
$ dig @127.0.0.1 xyz
```

## Reference

1. <https://github.com/skynetservices/skydns>
