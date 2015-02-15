# DNSMASQ On Ubuntu

I don't the default dnsmasq that managed by Network Manager.

## Install package

```
$ sudo apt-get install dnsmasq dnsmasq-base
```

## Configure dnsmasq

File: /etc/dnsmasq.conf

```
listen-address=127.0.0.1
resolv-file=/etc/resolv.dnsmasq.conf
```

File: /etc/resolv.dnsmasq.conf

```
options timeout:1
nameserver 223.5.5.5
nameserver 8.8.8.8
```

## Ingore resolvconf

File: /etc/default/dnsmasq

```
# sed -i 's/^#IGNORE_RESOLVCONF=yes/IGNORE_RESOLVCONF=yes/g' /etc/default/dnsmasq
```

## Start dnsmasq

```
$ sudo service dnsmasq start
```

## Configure DHCP

File: /etc/dhcp/dhclient.conf

Ensure below lines are inside:

```
prepend domain-name-servers 127.0.0.1;
```

## Remove the Network Manager controlled dnsmasq

```
# sed -i 's/^dns=dnsmasq/# dns=dnsmasq/g' /etc/NetworkManager/NetworkManager.conf
# service network-manager restart
```

## Add custom resolve

File: /etc/dnsmasq.d/custom.host

```
address=/.csdn.net/127.0.0.1
address=/.360.cn/127.0.0.1
address=/.360.com/127.0.0.1
address=/.360safe.com/127.0.0.1
address=/.qihoo.com/127.0.0.1
```

## Restart dnsmasq

```
$ sudo service dnsmasq restart
```

## Reference

https://help.ubuntu.com/community/Dnsmasq
