# iperf

使用 iperf3 做网络带宽测试，Network Bandwidth Testing.

## 下载安装

```
sudo wget -O /usr/lib64/libiperf.so.0 https://iperf.fr/download/ubuntu/libiperf.so.0_3.1.3
sudo wget -O /usr/bin/iperf3 https://iperf.fr/download/ubuntu/iperf3_3.1.3
sudo chmod +x /usr/bin/iperf3
```

## 使用

### 服务端

```
iperf3 --server --port 5201
```

### 客户端

```
iperf3 --client server-ip-address --port 5201 --time 60 -w 2M
```

## NUMA亲和

```
lscpu

taskset -c 0-5 iperf3 --server/--client
```

## 错误

如遇到如下错误：

> iperf3: error - socket buffer size not set correctly

https://github.com/esnet/iperf/issues/757#issuecomment-401173762

在客户端与服务端运行如下命令：

```
sysctl -w net.core.wmem_max=67108864
sysctl -w net.core.rmem_max=67108864
sysctl -w net.ipv4.tcp_rmem="4096 87380 33554432"
sysctl -w net.ipv4.tcp_wmem="4096 65536 33554432"
```
