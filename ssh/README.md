# SSH

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

## SSH 做安全隧道

### SSH做socket代理

```
$ ssh -D 7070 -fnN root@x.x.x.x
$ ssh -D 172.0.0.1:7070 -fnN root@x.x.x.x
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
