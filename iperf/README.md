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
