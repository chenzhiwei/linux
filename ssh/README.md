# SSH

是时候与时俱进了，使用`ed25519`类型的密钥。而 RSA 类型的密钥需要4096位了，实在太长了。

## SSH Import

突然发现Ubuntu下有个包`ssh-import-id`，可以自动导入用户在Launchpad或Github上的ssh key，于是打开脚本看一下发现如下：

Github API:

```
https://github.com/username.keys
https://api.github.com/users/username/keys
```

Launchpd API:

```
https://launchpad.net/~username/+sshkeys
```

将里面的`username`替换一下就能得到别人的ssh key了，想对别人授权时更容易了。


## SSH Key Info

The Private key contains the public key and the comment, you can only backup the private key.

### Generate SSH Key Pair

```
ssh-keygen -t ed25519 -C "zhiwei@ubuntu"
```

> 在旧系统上使用`ssh-keygen -t rsa -b 4096`

### Export Public Key from Private Key

```
ssh-keygen -y -f id_ed25519 > id_ed25519.pub
```

### Get RSA public key fingerprint

```
ssh-keygen -l -f id_ed25519
ssh-keygen -l -f id_ed25519.pub
```

### Update the comment in Private Key

```
ssh-keygen -c -f id_ed25519 -C "the new comment"
```

### Convert Private Key from OpenSSH to PEM(RSA)

```
ssh-keygen -p -N"" -m PEM id_ed25519
```

### Convert Private Key from PEM(RSA) to OpenSSH

```
ssh-keygen -p -N"" id_ed25519
```


## SSH Client

配置文件路径：`/etc/ssh/ssh_config` 和 `~/.ssh/ssh_config`。

### 提高登录速度

修改配置文件如下：

```
CheckHostIP no
GSSAPIAuthentication no
GSSAPIDelegateCredentials no
```

有时如果你机器的DNS有问题也会导致登录非常慢的，可以给修改一下DNS的配置，设置一下超时时间。

在`/etc/resolv.conf`里添加如下配置：

```
options timeout:1
```

### 避免登录时有交互

通常第一次登录时会检查服务的key是否在本地存在，如果不存在的话会提醒你保存的。

```
StrictHostKeyChecking no
```

以上配置顶均可以在执行`ssh`命令时进行配置，如下：

```
ssh -o StrictHostKeyChecking=no root@127.0.0.1
```

还有就是当机器重建之后登录时会提示`WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`，我非常不喜欢这个提示。所以直接修改配置文件：

```
UserKnownHostsFile /dev/null
```

世界清静了！！！

## SSH 做安全隧道

### SSH做socket代理

```
$ ssh -D 7070 -fnN -o ServerAliveInterval=60 root@x.x.x.x
$ ssh -D 172.0.0.1:7070 -fnN -o ServerAliveInterval=60 root@x.x.x.x
```

执行如上命令之后你就可以用主机`127.0.0.1`和端口`7070`做socket代理了。

### SSH做端口映射

host1可以通过SSH来登录server1，现在有以下需求：

* 将`host1:8080`映射到`server1:8080`上面，即访问`host1:8080`就相当于访问`server1:8080`。

一般这种情况是`server1`只开放了SSH端口（22），而其他端口没有开放，或者你能连接`host1`而无法连接`server1`。

你想访问`server1`的端口时可以在`host1`上执行使用如下命令：

```
$ ssh -fnN -L host1:8080:server1:8080 root@server1
```

执行完该命令之后用`netstat`查看`host1`就会发现多了个`8080`端口，而创建该端口的进程则是`ssh`。

* 将`server1:8080`映射到`host1:8080`上面，即访问`server1:8080`就相当于访问`host1:8080`。

一般这种情况是`host1`可以连接`server1`，而`server1`却不能连接`host1`时使用，在`host1`上执行如下命令：

```
$ ssh -fnN -R server1:8080:host1:8080 root@server1
```

执行完该命令之后用`netstat`查看`server1`就会发现多了个`8080`端口，而创建该端口的进程则是`sshd`。

## SSH Server

### 修改SSH登录的提示信息

这里的提示信息是登录前的提示信息，也就是说这个信息是在你输入密码之前就已经能看到了。

在SSH Server配置文件`/etc/ssh/sshd_config`里添加如下配置：

```
Banner /etc/ssh/message_file
```

然后`/etc/ssh/message_file`里的内容就是登录ssh server时的提示内容。


## 用代理方式登录 SSH 服务器

```
vim ~/.ssh/config
Host youya.org
    User root
    ProxyCommand nc -X 5 -x localhost:1080 %h %p
```

其中`-X 5`的意思是使用 socks5 协议，`-x localhost:1080`就是 socks5 的代理地址了，这两个都是 nc 的参数。

如果你的代理是 HTTP 代理，可以这样配置：


```
vim ~/.ssh/config
Host youya.org
    User root
    ProxyCommand nc -X connect -x localhost:3128 %h %p
```

## Issues

### debug1: expecting SSH2_MSG_KEX_DH_GEX_GROUP

当使用SSH登录时，一直停留在这里，最后出现了个`connection reset by peer`。查询了一下google，找到了解决方法：

`/etc/ssh/ssh_config`里需要去掉以下两行的注释。

```
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160
```

参考这里： <http://www.held.org.il/blog/2011/05/the-myterious-case-of-broken-ssh-client-connection-reset-by-peer/>

和这里： <http://superuser.com/questions/568891/ssh-works-in-putty-but-not-terminal>

### 在Server端设置了公钥但是Client用私钥登录时依旧让输入密码

SELinux导致的，执行如下命令就可以解决了：

```
restorecon -R -v /root/.ssh
```

参考： <http://www.unix.com/unix-advanced-expert-users/174645-openssh-5-3-needs-password-vs-4-3-using-private-keys.html>

### SSH 无法使用 key 方式来登录

有个原因是因为用户的 HOME 目录权限或属主被谁修改了，拿`root`用户来说，正常情况应该是

```
[root@rhel1 ~]# ls -dl /root
dr-xr-x---. 21 root root 4096 May 30 23:03 /root
```

很多时候不能用私钥登录的原因就是`/root`的属主被修改成其他用户了，只需要用如下命令简单修改回来：

```
chown -R root:root /root
```
