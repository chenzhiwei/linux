## rsync

rsync(remote sync)是一个UNIX系统下的文件同步、传输和备份工具。rsync是用`rsync`算法提供了一个客户机和远程文件服务器的文件同步的快速方法。rsync不仅能用于主机内文件的传输和备份也能用于不同网络主机的文件备份。

## rsync作为服务端使用时的配置文件有如下选项：

* uid/gid 文件目录的权限

* use chroot rsync在传送文件之间先chroot到模块（path）的目录

* max connections 最大连接数

* timeout 连接超时时间，防止客户端占用连接数

* [ftp] ftp为rsync的模块名称，之后的均为该模块里的配置

* hosts allow 允许哪些机器及网段访问（可以用通配符来匹配主机名）

* hosts deny 不解释

* path 模块所映射的服务端路径

* auth users 允许哪些用户连接（通过密码）

* read only 是否只读权限

* write only 是否只写权限

* secrets file 当使用`auth users`时，存放用户的密码的文件

* list 是否允许列出模块目录中的文件

其中大部分选项都支持全局配置，典型的配置文件请参考同级目录下的`rsyncd.conf`和`rsyncd.secrets`文件。

注： rsync作为服务端时有两种启动命令，分别是`rsync --daemon`和`inetd`方式，其中第一种方式是客户端每次连接都会重新读取其配置文件，而第二种方式需要在配置文件修改之后给inetd发一个HUP信号。推荐使用`rsync --daemon`方式使用rsync。在`/etc/inetd.conf`中添加以下内容：

```
rsync   stream  tcp     nowait  root   /usr/bin/rsync rsyncd --daemon
```

### rsync作为客户端时常用的命令：

假设服务端host为`host.name`，ftp模块需要用户名test和密码123456来读写，www模块只允许10.0.0.0/8网段的用户读写。

```
$ rsync source_file test@host.name::ftp
$ rsync -a source_dir test@host.name::ftp
$ rsync source_file --password-file=/tmp/rsync.pwd test@host.name::ftp
$ rsync host.name::www
```

用rsync快速删除本地或远端文件（速度非常快）：

假如本地有个目录`/var/files`，里面的文件有N多G，非常大，如果用rm命令的话会非常慢，用rsync的话就会很快。

```
$ mkdir /tmp/empty
$ rsync -a --delete /tmp/empty /var/files
```

用rsync快速删除远端指定文件`test.file`：

```
$ rsync -rv --delete --include=test.file --exclude=*  /tmp/empty dest/
$ rsync -d --exclude=test.file --filter="R test.file" --filter="P *" \
        --delete-excluded --existing --ignore-existing . user@rsync_server::module
```

## rsync包含以下特性：

* 能更新（镜像）整个目录树和文件系统
* 有选择性的保持符号链接、硬链接、文件属性、权限、设备以及时间
* 对于安装来说，无任何特殊要求
* 对于多个文件来说，内部流水线减少文件等待的延时
* 能用rsh、ssh或直接用端口作为传输入端口
* 支持匿名rsync同步文件，是理想的镜像工具

## rsync服务器架设及使用简单

```
# yum install rsync
# mkdir /etc/rsyncd
# touch /etc/rsyncd/rsyncd.conf
# touch /etc/rsyncd/rsyncd.secrets
# chmod 600 /etc/rsyncd/rsyncd.secrets
# touch /etc/rsyncd/rsyncd.motd
```

易知，rsyncd.conf为rsync服务器的配置文件。

假如我们要备份机器上的/home目录，但不包括/home目录中的tmp和temp目录。并且我们只允许10.3.2.0/24网段的IP以只读方式访问，用户名为zhiwei，密码在rsyncd.secrets文件中，下面是一个简单的示例文件rsyncd.conf：

```
# This line is required by the /etc/init.d/rsyncd script
pid file = /var/run/rsyncd.pid
port = 873
# rsync's default port
address = 10.3.2.5
# rsync server's ip address
#uid = nobody
#gid = nobody
uid = root
gid = root
# uid和gid是指从服务器端下载文件时用哪个用户和用户组来进行，这里写root是为了防止遇到权限问题导致部分文件没法下载下来。
use chroot = yes
read only = yes
#limit access to private LANs
hosts allow=10.3.2.0/255.255.255.0 10.3.5.0/255.255.255.0
hosts deny=*
max connections = 5
motd file = /etc/rsyncd/rsyncd.motd
# motd file 是定义服务器信息的，要自己写 rsyncd.motd 文件内容。当用户登录时会看到这个信息。
#This will give you a separate log file
#log file = /var/log/rsync.log
#This will log every file transferred - up to 85,000+ per user, per sync
#transfer logging = yes
log format = %t %a %m %f %b
syslog facility = local3
timeout = 300
[myhome]
path = /home
list=yes
ignore errors
auth users = zhiwei
secrets file = /etc/rsyncd/rsyncd.secrets
comment = linux home
exclude = tmp/ temp/
rsyncd.secrets的格式为： 用户名:密码

zhiwei:12345
chen:123456

rsyncd.motd

++++++++++++++++++++++++++++++++++++++++
+ sinaapp.com rsync 2011-2012 +
++++++++++++++++++++++++++++++++++++++++

启动rsync服务器 # /usr/bin/rsync –daemon –config=/etc/rsyncd/rsyncd.conf

查看rsync服务器上有哪些可用文件 # rsync –list-only 10.3.2.5:: 或者： # rsync –list-only zhiwei@10.3.2.5

同步可用文件 # rsync -avzP 10.3.2.5::myhome /var/homebak 或 # rsync -avzP zhiwei@10.3.2.5::myhome 然后等待输入密码

还有自动同步脚本，这里就不再写出了。
```
