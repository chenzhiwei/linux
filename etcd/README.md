# etcd

etcd is a distributed, consistent key value store for shared configuration and service discovery.

## 安装

有很多参数可以使用的，具体看文档就行了。

### Linux amd64

```
# curl -L  https://github.com/coreos/etcd/releases/download/v2.0.4/etcd-v2.0.4-linux-amd64.tar.gz -o etcd-v2.0.4-linux-amd64.tar.gz
# tar xf etcd-v2.0.4-linux-amd64.tar.gz
# cd etcd-v2.0.4-linux-amd64
# ./etcd
```

### Docker

```
# export HostIP=192.168.122.11
# docker run -d -v /usr/share/ca-certificates/:/etc/ssl/certs -p 4001:4001 -p 2380:2380 -p 2379:2379 \
    --name etcd quay.io/coreos/etcd \
    -name etcd0 \
    -advertise-client-urls http://${HostIP}:2379,http://${HostIP}:4001 \
    -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
    -initial-advertise-peer-urls http://${HostIP}:2380 \
    -listen-peer-urls http://0.0.0.0:2380 \
    -initial-cluster-token etcd-cluster-1 \
    -initial-cluster etcd0=http://${HostIP}:2380 \
    -initial-cluster-state new
# curl http://127.0.0.1:4001/version
# docker exec etcd /etcdctl help
```

## 使用

### 设置一个Key/Value

```
$ curl -X PUT -d value="the value of /key_name" http://127.0.0.1:4001/v2/keys/key_name
```

### 获取一个Key的值

```
$ curl http://127.0.0.1:4001/v2/keys/key_name
```

### 删除一个Key

```
$ curl -X DELETE http://127.0.0.1:4001/v2/keys/key_name
```

### 为一个Key设置失效时间

```
$ curl -X PUT -d ttl=60 -d value="the value of /key_ttl" http://127.0.0.1:4001/v2/keys/key_ttl
```

### 创建一个directory

directory有点像namespace，一个directory下面可以有多个key。例如：每个服务有自己的directory，而这个服务的各种配置都放在它的directory下面。

```
$ curl -X PUT -d value="the value of /dir/key" http://127.0.0.1:4001/v2/keys/dir/key
```

通常directory是随着创建key而自动建立，然而某些情况下你可能需要创建一个空的directory，那么就可以用以下方法了。

```
$ curl -X PUT -d dir=true http://127.0.0.1:4001/v2/keys/dir
```

### 获取一个directory

```
$ curl http://127.0.0.1:4001/v2/keys/dir
$ curl 'http://127.0.0.1:4001/v2/keys/dir?recursive=true'
```

### 删除一个directory

```
$ curl -X DELETE 'http://127.0.0.1:4001/v2/keys/dir?dir=true'
$ curl -X DELETE 'http://127.0.0.1:4001/v2/keys/dir?recursive=true'
```

### 获取所有的key

```
$ curl -s http://127.0.0.1:4001/v2/keys?recursive=true | python -m json.tool
```

## Reference

1. <https://github.com/coreos/etcd>
2. <https://github.com/coreos/etcd/releases>
3. <https://github.com/coreos/etcd/blob/master/Documentation/api.md>
4. <https://github.com/coreos/etcd/blob/release-2.3/Documentation/docker_guide.md>
