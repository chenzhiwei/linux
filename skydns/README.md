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
# ./skydns
```

### Docker

```
# docker run -d -p 172.17.42.1:53:53/udp --name skydns skynetservices/skydns -machines="http://172.17.42.1:4001" -addr="0.0.0.0:53" -nameservers="8.8.8.8:53"
```

## 设置一个域名

SkyDNS默认domain是`skydns.local`，当然你也可以在启动时用`-domain='custom.local'`来指定。

### abcd.skydns.local 解析到 10.0.0.1

```
$ curl -X PUT http://172.17.42.1:4001/v2/keys/skydns/local/skydns/abcd -d value='{"host": "10.0.0.1"}'
$ dig @127.0.0.1 abcd.skydns.local
```

### xyz.abc.skydns.local 解析到 10.0.0.2

```
$ curl -X PUT http://172.17.42.1:4001/v2/keys/skydns/local/skydns/abc/xyz -d value='{"host": "10.0.0.2"}'
$ dig @127.0.0.1 xyz.abc.skydns.local
```

### 设置/etc/resolv.conf

如果你想让你的机器能直接通过`abcd`和`xyz.abc`来访问，你可以设置`/etc/resolv.conf`为以下内容。

```
domain skydns.local
nameserver skydns-ip-address
```

## SkyDNS

SkyDNS其实是个非常简单的DNS发现服务，不要企求有太多功能。

## Reference

1. <https://github.com/skynetservices/skydns>
