# CentOS Tips

## Install essential packages

```
# yum -y install vim autoconf automake make cmake gcc gcc-c++ gdb telnet nmap nfs-utils rsync wget createrepo rpm-build rpm-sign cpio tcpdump sysstat subversion git strace python-setuptools ppp pptp gnupg fuse ntp ntpdate tree net-tools
```

## Disable SELinux

```
# sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config
```

## Disable Firewall

```
# systemctl stop firewalld.service iptables.service
# systemctl disable firewalld.service iptables.service
```

## Set DNS Server
