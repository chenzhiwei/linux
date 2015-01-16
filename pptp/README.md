# PPTP

Point to Point Tunneling Protocol. Base on PPP protocol and work on Layer 2, is likely L2TP.

## Build PPTP Server

### Install PPTPD

* Ubuntu

```
# apt-get install ppp pptpd
```

* CentOS/RHEL

```
# yum install ppp pptpd
```

### Edit configuration file

* /etc/pptpd.conf

```
localip 10.10.0.1
remoteip 10.10.0.10-20
```

remoteip 会被添加到PPTP Client机器的`ppp0`虚拟网卡，该虚拟网卡会在客户端连接服务端成功之后生成。

* /etc/ppp/chap-secrets

```
username1 * userpass1 *
username2 * userpass2 *
```

* /etc/ppp/options.pptpd

```
ms-dns 8.8.8.8
ms-dns 8.8.4.4
```

这个是可选配置。

* /etc/sysctl.conf

```
net.ipv4.ip_forward = 1
```

使用`sysctl -p`来使改动生效。

### 配置防火墙

```
# iptables -A INPUT -i eth0 -p tcp --dport 1723 -j ACCEPT
# iptables -A INPUT -i eth0 -p gre -j ACCEPT
# iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# iptables -A FORWARD -i ppp+ -o eth0 -j ACCEPT
# iptables -A FORWARD -i eth0 -o ppp+ -j ACCEPT
# service iptables save
# service iptables restart
```

### 启动PPTP Server

```
# service pptpd restart
```

## Build PPTP Client

### Install PPTP Client

* Ubuntu

```
# apt-get install ppp pptp
```

* CentOS/RHEL

```
# yum install ppp pptp
```

### Edit configuration file

* /etc/ppp/chap-secrets

```
username1 PPTP userpass1 *
```

里面的`username1`和`userpass1`分别是你在PPTP Server上配置的用户名和密码。

* /etc/ppp/peers/vpn-connection1

```
pty "pptp pptpd-server-address --nolaunchpppd"
name username1
remotename PPTP
require-mppe-128
file /etc/ppp/options.pptp
ipparam vpn-connection1
```

你需要将上面的`pptpd-server-address`和`username1`改成你自己的PPTP Server地址（IP或域名）和用户名。

* /etc/ppp/ip-up.d/router-for-vpn-connection1

```
#/bin/bash
ip route add 10.0.0.0/8 via 10.10.0.10
```

给该文件加上可执行权限`chmod +x /etc/ppp/ip-up.d/router-for-vpn-connection1`。

当然，你也可以将`10.10.0.10`设置成你的默认路由，这样大部分流量都走这个PPTP了。

### 连接PPTP Server

```
# pppd call vpn-connection1
```

## Trouble Shooting

你可以查看Server和Client的`/var/log/message`文件如果你遇到什么问题的话。

## Reference

1.<http://www.photonvps.com/billing/knowledgebase.php?action=displayarticle&id=58>

2.<http://www.cyberciti.biz/tips/howto-configure-ubuntu-fedora-linux-pptp-client.html>
