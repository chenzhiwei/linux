# UCarp

## Start UCarp

* vip: 10.0.0.10
* node1: 10.0.0.11
* node2: 10.0.0.12

### On node 10.0.0.11

```
ucarp --interface=eth0 --srcip=10.0.0.11 --vhid=10 --pass=10.0.0.10 --addr=10.0.0.10 --upscript=/etc/vip-up.sh --downscript=/etc/vip-down.sh
```

### On node 10.0.0.12

```
ucarp --interface=eth0 --srcip=10.0.0.12 --vhid=10 --pass=10.0.0.10 --addr=10.0.0.10 --upscript=/etc/vip-up.sh --downscript=/etc/vip-down.sh
```
