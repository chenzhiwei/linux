# DNSMASQ 是个好东东

## 安装

```
$ sudo apt-get install dnsmasq dnsmasq-base
```

## 配置

```
# vim /etc/dnsmasq.conf
listen-address=127.0.0.1
server=/company.com/10.0.0.1
address=/double-click.net/127.0.0.1
resolv-file=/etc/resolv.dnsmasq.conf
```

解释一下每行的意思：

* server=/company.com/10.0.0.1

    意思是用 DNS Server `10.0.0.1` 来解析`company.com`相关的域名。很多公司都有自己的 DNS Server 并解析公司内部域名和外部域名，这个 DNS Server 和公共 DNS Server 相比起来太弱了，没法分域解析一些较大网站的域名，比如我们公司是电信网，却把百度解析到了联通上面，导致网速变慢。

* address=/double-click.net/127.0.0.1

    意思是将`double-click.net`解析到`127.0.0.1`上面，这是正则匹配的，比`/etc/hosts`文件强大多了。

* resolv-file=/etc/resolv.dnsmasq.conf

    DNSMasq 默认会去`/etc/resolv.conf`里找 DNS Server ，我们要让它从`/etc/resolv.dnsmasq.conf`里找，这里定义公共的 DNS Server ，比如阿里的`223.5.5.5`和`223.6.6.6`，而`/etc/resolv.conf`里的 DNS Server 写`127.0.0.1`。

```
# vim /etc/resolv.dnsmasq.conf
nameserver 223.5.5.5
nameserver 8.8.8.8
search domain.root
```

## Ubuntu 下的配置

第一步就是设置系统 DNS Server ，下面章节有详细设置方法，设置好之后可以直接在`/etc/dnsmasq.d`目录里添加配置文件，然后就自动生效了。

通常我们都是将 DNS Server 设置成公共的，然后把公司的内网域名解析写到`/etc/dnsmasq.d`目录的配置文件里，比如：

```
# vim /etc/dnsmasq.d/mycompany
server=/mycompany.com/10.0.0.1
server=/mycompany.net/10.0.0.1
```

<!--
### 忽略 resolvconf 这个东东

File: /etc/default/dnsmasq

```
# sed -i 's/^#IGNORE_RESOLVCONF=yes/IGNORE_RESOLVCONF=yes/g' /etc/default/dnsmasq
```

### 配置 DHCP

这里主要是让 DHCP 将 `/etc/resolv.conf` 的值设置为`nameserver 127.0.0.1`，也就是 dnsmasq 的地址。

File: /etc/dhcp/dhclient.conf

Ensure below lines are inside:

```
prepend domain-name-servers 127.0.0.1;
```

### 删除 Network Manager 管理的 dnsmasq

```
# sed -i 's/^dns=dnsmasq/# dns=dnsmasq/g' /etc/NetworkManager/NetworkManager.conf
# service network-manager restart
```

### 自定义域名解析

File: /etc/dnsmasq.d/custom.host

```
address=/.csdn.net/127.0.0.1
address=/.360.cn/127.0.0.1
address=/.360.com/127.0.0.1
address=/.360safe.com/127.0.0.1
address=/.qihoo.com/127.0.0.1
```
-->

## 重启各个服务

```
# service NetworkManager restart
# service dnsmasq restart
```

## 我只想改系统的 nameservers

* 方法一：

点击网络图标，然后`Edit Connections...`，选择网卡点击`Edit`，然后切换到`IPv4 Settings`，将 Method 改为`Automatic(DHCP) addresses only`，然后填写 DNS Servers 为`223.5.5.5,223.6.6.6`，保存退出即可。

* 方法二：

```
# sed -i 's/^dns=dnsmasq/# dns=dnsmasq/g' /etc/NetworkManager/NetworkManager.conf
# vim /etc/dhcp/dhclient.conf
prepend domain-name-servers 223.5.5.5,8.8.8.8;
prepend domain-search "domain.root","dm.root";
# service NetworkManager restart
```

<!--
## Mac OSX

```
$ brew install dnsmasq
$ cp /usr/local/opt/dnsmasq/dnsmasq.conf.example /usr/local/etc/dnsmasq.conf
$ vim /usr/local/etc/dnsmasq.conf
$ sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
$ sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
$ sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist # use unload to stop
```
-->

## Others

<https://www.stgraber.org/2012/02/24/dns-in-ubuntu-12-04/>

<https://cweiske.de/tagebuch/networkmanager-dnsmasq.htm>
