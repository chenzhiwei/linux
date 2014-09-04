## rsync

rsync(remote sync)是一个UNIX系统下的文件同步、传输和备份工具。rsync是用`rsync`算法提供了一个客户机和远程文件服务器的文件同步的快速方法。rsync不仅能用于主机内文件的传输和备份也能用于不同网络主机的文件备份。

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
