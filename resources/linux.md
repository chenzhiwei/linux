# Linux 常用命令

## Apache Server 大文件 403 forbidden

一般都是由于开启 SELinux 导致的，并且我只在 RHEL 上遇到过。关闭 SELinux 并重启 httpd 即可。

```
# setenforce 0
# service httpd restart
```

## SSHD 允许以 root 用户登录

```
$ cat /etc/ssh/sshd_config
PermitRootLogin yes
```

## sudo username 无需密码

```
$ cat /etc/sudoers
username ALL=(ALL) NOPASSWD:ALL
```

## ls 时文件名后跟了个特殊符号

```
$ ls -F /usr/bin/diff
/usr/bin/diff*
$ ls -F /var/run/docker.sock
/var/run/docker.sock=
```

当`ls`命令跟参数`-F`时会在文件名后面加上个特殊符号

* directories /
* sockets =
* symbolic links @
* executables *

## 运行 screen 命令出错

```
Cannot open your terminal '/dev/pts/0' - please check.
```

通常是由于你`su - user`导致的，可以用标准的用户`user`登录进去运行，或者`script /dev/null`。

## 将字符串分割成单个字符

```
$ echo abcd | grep -o .
```

## 修改文件名大小写

```
$ mv $file $(echo $file | tr 'A-Z' 'a-z')
```

## 配置 RHEL 路由

```
# vim /etc/sysconfig/network-scripts/route-eth0
9.0.0.0/9 via 9.111.250.1
```

### 删除tar包解压后的文件

有时你解压一下tar包时，这个tar包并没有一个主目录，结果把自己当前的目录搞混乱了，你都不知道哪个文件是从这个tar包里解压出来的了。

```
rm -rf "$(tar ztf filename.tar.gz)"
```

不过，还是有个问题，就是这个压缩包里的目录并不会被删除。

### /etc/shadow 文件各字段说明

```
zhiwei:$6$jQxzk6zH$.mTIBeVixdlJ7kOgad6wci:16412:0:99999:7:::
```

As with the passwd file, each field in the shadow file is also separated with ":" colon characters, and are as follows:

* Username, up to 8 characters. Case-sensitive, usually all lowercase. A direct match to the username in the /etc/passwd file.
* Password, 13 character encrypted. A blank entry (eg. ::) indicates a password is not required to log in (usually a bad idea), and a `*` entry (eg. :*:) indicates the account has been disabled.
* The number of days (since January 1, 1970) since the password was last changed.
* The number of days before password may be changed (0 indicates it may be changed at any time)
* The number of days after which password must be changed (99999 indicates user can keep his or her password unchanged for many, many years)
* The number of days to warn user of an expiring password (7 for a full week)
* The number of days after password expires that account is disabled
* The number of days since January 1, 1970 that an account has been disabled
* A reserved field for possible future use

查看密码过期时间及相关信息：

```
# chage -l zhiwei
Last password change                    : Dec 08, 2014
Password expires                    : never
Password inactive                   : never
Account expires                     : never
Minimum number of days between password change      : 0
Maximum number of days between password change      : 90
Number of days of warning before password expires   : 7
```

以上意思是密码至少需要每90天修改一次。

你可以使用如下命令来修改密码不过期：

```
# chage -M 99999 zhiwei
# chage zhiwei
```

或者直接编辑`/etc/shadow`文件，将第五列修改为`99999`，意思是这个密码274年之后才会过期，也就是说永不过期了。

### VIM检查文件类型

```
:set filetype?
:set ft?
:set ft=php
:echo &ft
:echo &tabstop
```

### 格式化Json文件

```
$ cat xxx.json | python -m json.tool
```

### 进入单用户模式修改root密码

开机时在kervel的那一行后面添加`1`或`single`，然后boot系统。（也可以顺便加上`selinux=0`）

重启之后进入系统直接输入`passwd`命令来修改密码，如果输入`passwd`命令没有任何输出，一般原因是没有关闭SELinux。

可以使用`getenforce`来查看是否关闭了SELinux，如果没有那么可以使用`setenforce 0`来临时关闭SELinux，然后再修改密码。

如果以上还不行，那么就清除`/etc/shadow`第一个`:`后面的密码加密后的字符串。

### 开机时进入了repair filesystem模式（即文件系统修复模式）

出现这个问题一般有两个原因：

1.非正常关机导致，解决方法如下：

可以用`fsck`命令来修复一个磁盘，直接输入`fsck`或`fsck /dev/hdX`。

2.`/etc/fstab`文件里格式错误，修正之后重启机器就可以了。

在repair filesystem模式下，文件系统是只读的，需要先将`/`挂载为读写模式，然后再修改，方法如下：`mount -o remount,rw /`。

### 程序编译时及运行时所调用的库

查看程序运行时所调用的so库文件顺序并不完全和`ldconfig -p`出来的一致，因为程序可能会有一个`rpath`选项来指定默认的调用路径，用以下命令可以查看： `readelf -d /usr/lib64/xxx.so`

### 备份与恢复MBR

MBR(Master Boot Record) Total Size: 446 + 64 + 2 = 512

446 bytes - Bootstrap.

64 bytes - Partition table.

2 bytes - Signature.

```
# dd if=/dev/sda of=mbr.img bs=512 count=1
# dd if=mbr.img of=/dev/sda bs=512 count=1
```

### 修改Linux系统临时目录路径

通常遇到系统`/tmp`目录太小时使用

```
$ export TMP=/xxx
$ export TEMP=/xxx
$ export TMPDIR=/xxx
```

### 生成openstack tar包，供rpm sepc文件使用

the tar package will be generated in dist dir

    PBR_VERSION=2013.2.3 python setup.py sdist

### VIM删除以某字符开始的行

    :g/^#.*/d

### 生成shadow password

    $ openssl passwd -1 "theplaintextpassword"
    $ mkpasswd -m sha-512

### 卸载Linux图形界面

    # yum groupremove "GNOME Desktop Environment"
    # yum groupremove "X Window System"
    # vim /etc/inittab # content is
    id:3:initdefault

### SSH做socket代理用

    $ ssh -D 7071 -fnN root@10.2.2.5

### SHELL的TCP编程

    $ exec 5<>/dev/tcp/baidu.com/80
    $ echo -e "GET / HTTP/1.0\r\n" >&5
    $ cat <&5
    $ exec 8<&- # 也可以这样写 exec 8>&-

其中5为文件描述符，`n<>filename.txt`表示以文件描述符n来打开filename.txt这个文件进行读写操作，建立连接之后可以在`/proc/self/fd`目录下面看到。

### SHELL随机生成MAC地址

    MACADDR="fa:16:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')"

### SHELL的fork炸蛋

    $ : () { : | : & } ; :

命令行执行以下命令会一直fork进程，注意`:`是函数名，然后就能理解是怎么回事了。

### 调整Linux磁盘预留空间大小

大部分文件系统都会保留一部分预留空间，以备紧急时使用（平时磁盘空间为100%时仍然可以写入文件就是这个道理）。ext3/ext4是默认预留5%的磁盘空间，如果你的磁盘是1T的话，那么就会有50G的空间作为预留空间。可以用以下命令来改变磁盘预留空间的大小。

    # tune3fs -m 2 /dev/vdb1

将/dev/vdb1分区的预留空间改为2%

### 令人蛋疼的网卡名字em1-em2...

这个一般是在CentOS6.x之中出现，解决方法是：

1. 删除(修改也行)/etc/udev/rule.d/70-persistent-net.rules
2. 重命名及修改/etc/sysconfig/network-scripts/ifcfg-em1 -> ifcfg-eth0
3. 在/etc/grub.conf的内核启动参加一行最后添加： biosdevname=no
4. reboot your system and eth0 will come back

### 使用udev强制使默认网卡为eth1

创建文件：/etc/udev/rules.d/70-persistent-net.rules

写入以下内容

    SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="??:??:??:??:??:??", ATTR{type}=="1", KERNEL=="eth*", NAME="eth1"

## redis相关命令

    http://redis.io/commands
    更改主从： slaveof host port
    更改为主： slaveof no one
    缩小aof文件大小： bgrewriteaof
    动态修改配置文件： config get * / config set key val
    日志文件rotate： 日志文件是以reopen方式打开的，因此可以直接删除或压缩


### CentOS禁用IPv6

http://wiki.centos.org/FAQ/CentOS5#head-47912ebdae3b5ac10ff76053ef057c366b421dc4

1. 修改/etc/sysconfig/network文件，添加以下一行内容

    NETWORKING_IPV6=no

2. centos5.4以后版本，修改/etc/modprobe.conf，添加以下内容：

    options ipv6 disable=1

### 挂载.img文件

    # mount -o loop[,offset=32256] root.img /mnt # offset为可选项

如果挂载不了，则使用以下命令挂载

    # kpartx -a /path/file.img
    # kpartx -l /path/file.img

第二条指令会输出类似于以下的内容：`loop0p1 : 0 16787862 /dev/loop0 63`

直接挂载/dev/loop0就可以了： mount /dev/loop0 /mnt

### 格式化磁盘命令

    # echo -e "n\np\n1\n\n\nw" > /tmp/fdiskcmd.txt
    # fdisk /dev/hdb < /tmp/fdiskcmd.txt

（fdisk /dev/hdb 然后按n,p,1,[可以直接回车，也可以按提示操作],回车,w）

    # partprobe
    # /sbin/mkfs.ext3/dev/hdb1
    # mkdir /data0
    # mount /dev/hdb1 /data0
    # echo "/dev/hdb1 /data0 ext3 defaults 0 0" >> /etc/fstab
    # rm -f /tmp/fdiskcmd.txt

其实可以这样操作：

    # fdisk /dev/vdb <<EOF
    n
    p
    1
    [2]


    w
    EOF

### 获取脚本所在的绝对路径

    $ dirname `readlink -f $0`
    $ cd $(dirname "$0") && pwd

### 给机器添加及删除IP地址

    # ip -f inet addr add 10.67.15.127/24 brd 10.67.15.255 dev eth1
    # ip link set eth1 up
    # arping -s 10.67.15.127 -I eth1 -c 3 10.67.15.1 （将该地址广播给局域网中其他机器）
    # ip -f inet addr del 10.67.15.127/24 brd 10.67.15.255 dev eth1
    ## /usr/lib64/heartbeat/send_arp -i 200 -r 5 -p /var/run/heartbeat/rsctmp/send_arp/send_arp-10.75.7.127 eth1 10.75.7.127 auto not_used not_used

### 添加修改默认路由

    # ip route add default via 10.67.15.1
    # ip route change default via 10.66.15.1
    # ip route add 10.210.210.4 via 10.67.15.1
    # ip route add 10.210.211.0/24 via 10.67.15.1

### 添加网卡别名及分配IP地址

假设现在eth0的配置如下：inet 192.168.110.4/24 brd 192.168.110.255

现在需要新添加一个IP：192.168.110.10 ，执行命令如下：

    # ifconfig eth0:1 192.168.110.10 （添加别名及IP，完整命令如下：ifconfig eth0 192.168.6.99 netmask 255.255.255.0 up）
    # arping -s 192.168.110.10 -c 3 192.168.110.1（将该地址广播给局域网中其他机器）

创建/etc/sysconfig/network-scripts/ifcfg-eth0:1文件，对比ifcfg-eth0文件，修改成以下内容：

    BOOTPROTO="static"
    IPADDR="192.168.110.10"

### 修改登录成功后的提示信息

在此文件中添加内容即可：/etc/motd

motd = message of the day

### 挂载内存为某个可读写的分区1G

    none /memtmp tmpfs rw,size=1048576000 0 0

### 查看某进程真正的当前目录地址

即发出命令启动该进程时所在的目录

/proc/<进程pid>/cwd 为一个链接文件，这个文件所链接的地址就是进程真正的当时目录地址

ls -l /proc/process_pid/cwd 命令就可以看到了

在查找coredump文件时有用

### xargs命令中使用mv,cp

    $ ls | xargs -i mv {} /tmp
    $ ls | xargs mv --target-directory /tmp

### MegaCli命令相关

    查看磁盘信息： MegaCli -pdlist -aall
    查看RAID信息： MegaCli -ldinfo -lall -aall

### 给机器添加SWAP

    # dd if=/dev/zero of=/var/swap bs=200M count=10 # bs是block size的意思，创建的文件大小=bs*10
    # /sbin/mkswap/var/swap/sbin/swapon/var/swap

### 禁用Selinux

暂停： setenforce 0

启动时禁用： /etc/selinux/config 中将 SELINUX=enforcing改为 SELINUX=disabled

### 以其他session来启动程序

    # screen -dm sh start.sh
    # nohup ./start.sh &
    # exec ./start.sh & ; echo \$! > '$JETTY_PID'"

### lsof (list open files)

lsof 是一个列出当前系统打开文件的工具。在linux环境下，任何事物都以文件的形式存在，通过文件不仅仅可以访问常规数据，还可以访问网络连接和硬件。

    lsof输出各列信息的意义如下：
    COMMAND：进程的名称
    PID：进程标识符
    USER：进程所有者
    FD：文件描述符，应用程序通过文件描述符识别该文件。如cwd、txt等
    TYPE：文件类型，如DIR、REG等
    DEVICE：指定磁盘的名称
    SIZE：文件的大小
    NODE：索引节点（文件在磁盘上的标识）
    NAME：打开文件的确切名称

### 查看占用818端口的进程

    # lsof -i :818

### 查看httpd进程打开的文件

    # lsof -c httpd

### 利用lsof命令来恢复误删除的文件（/var/logs/deleted_file）

1. 查看是否有进程还在使用该文件： lsof | grep /var/logs/deleted_file
假设该命令输出结果为：httpd 32484 nobody 2w   REG  253,0 6047899181   3866629 /logs/error_log (deleted)
2. 从上面的信息可以看到 PID 32484（httpd），打开文件的文件描述符为 2。同时还可以看到/log/error_log已经标记被删除了。因此我们可以在 /proc/32484/fd/2 （fd下的每个以数字命名的文件表示进程对应的文件描述符）中查看相应的信息，命令如下(意思是查看该被删除文件的头10行)：# head -n 10 /proc/32484/fd/2
3. 恢复该文件： # cat /proc/32484/fd/2 >/tmp/file

### shell命令urlencode

    $ after=(echo -e "$before" | od -An -tx1 | tr ' ' % | xargs printf "%s")

### 压缩及解压缩

    # tar -zcvf tmp.tar.gz ./* #打包前压缩当前目录下的所有文件到 tmp.tar.gz，-z命令是压缩 gzip属性的包
    # tar -jcvf tmp.tar.bz2 ./* #打包前压缩当前目录下的所有文件到 tmp.tar.bz2，-j命令是压缩 bz2属性的包
    # tar -Zcvf tmp.zip ./* #打包前压缩当前目录下的所有文件到 tmp.zip，-Z命令是压缩 zip属性的包

相应的，将以上命令中的参数c改为x，则表示为解压缩
gzip,gunzip,uncompress,unzip

### 查看文件大小

查看当前目录下文件的大小：ls -lh （h是human的意思，即人类可读形式列出）

    # df -h （查看整个硬盘容量）
    # du -h test.tar.gz （查看test.tar.gz包的大小，-h是以友好形式展现）
    # du -sh dir （查看某个目录的大小，-h意思是以友好形式展现）
    # du -h （查看当前目录下所有文件的大小，包括子目录和文件。小心使用，不然会被刷屏的）

### 格式化输出date命令字符串

    # date -d today +%F-%T == date --date today +%F-%T == date +"%F-%T"
    # date -d 20110909 +%s
    # date -d "2011-09-09 09:09:09" +%s

将具体时间转为时间戳，其中2011-09-09之间的"-"不加也行，输出结果为：1315530549

    # date -d '19700101 UTC 1315530549 seconds' +"%F %T"
    # date -d'@1315530549' +"%F %T"

将时间戳转为具体时间，输出结果为：2011-09-09 09:09:09

### 输出本机IP地址

    # ip addr show | awk '/inet / {print $2}'|cut -f 1 -d '/'|grep -v 127.0.0.1|grep -v 192.168|head -1
    # ip addr show | awk -F"[ /]" '/inet / {if($6 ~ /10.67.15/){print $6;}}'

### 查看RPM包的安装位置

    rpm -qpl mod_dav_svn-1.6.11-7.el5.i386.rpm

### 查看某文件属于哪个RPM包

    rpm -qf /etc/haproxy.cfg

### 安装SRPM包

第一种方法

1.执行rpm -i your-package.src.rpm
2. cd /usr/src/redhat/SPECS
3. rpmbuild -bp your-package.specs 一个和你的软件包同名的specs文件
4. cd /usr/src/redhat/BUILD/your-package/ 一个和你的软件包同名的目录
5. ./configure 这一步和编译普通的源码软件一样，可以加上参数
6. make
7. make install

第二种方法

1.执行rpm -i you-package.src.rpm
2. cd /usr/src/redhat/SPECS
3. rpmbuild -bb your-package.specs 一个和你的软件包同名的specs文件

这时，在/usr/src/redhat/RPM/i386/ （根据具体包的不同，也可能是x86_64,noarch等等)

在这个目录下，有一个新的rpm包，这个是编译好的二进制文件。

执行rpm -i new-package.rpm即可安装完成。

### 打印文件树（打印目录树的话只需加上选项 -type d）

    find . -print 2>/dev/null|awk '!/\.$/ {for (i=1;i<NF;i++){d=length($i);if ( d < 5 && i != 1 )d=5;printf("%"d"s","|")}print "---"$NF}' FS='/'

### 创建指定大小的文件

创建一个名字为hello.txt大小为100M的文件

dd是把指定的输入文件拷贝到指定的输出文件中，并且在拷贝的过程中可以进行格式转换。

    # dd if=/dev/zero of=hello.txt bs=100M count=1

### cron各字段的含意（dom:day of month）

    m h dom mon dow user command
    分钟 小时 日 月 周 ［用户名］ 命令
    第一段应该定义的是：分钟，表示每个小时的第几分钟来执行。范围是从0-59，如果指定为*，则表示每分钟都执行
    第二段应该定义的是：小时，表示从第几个小时来执行，范围是从0-23
    第三段应该定义的是：日期，表示从每个月的第几天执行，范围从1-31
    第四段应该定义的是：月，表示每年的第几个月来执行，范围从1-12
    第五段应该定义的是：周，表示每周的第几天执行，范围从0-6，其中 0表示星期日。
    每六段应该定义的是：用户名，也就是执行程序要通过哪个用户来执行，这个一般可以省略；
    第七段应该定义的是：执行的命令和参数。
    示例：
    0. 如果第五个字段不为*，那么第三个字段会被忽略
    1. 每5分钟执行一次： */5 * * * * user command
    2. 每小时执行一次（这里是每小时的第1分钟执行）： 1 * * * * user command
    3. 每小时的第10分钟和第40分钟执行一次： 10,40 * * * * user command
    4. 每周日执行一次： 0 0 1-31 * 0 [user] command

### SHELL中使用浮点运算

    #!/bin/bash
    a=5
    b=4
    c=$(echo "scale=2; $a/$b" | bc) #scale意思是保留两位小数
    echo $c #c=1.25

### 删除所有目录中的某文件

如：删除所有目录中的.svn目录

    find . -type d -name ".svn" -print0 | xargs -0 rm -rf （防止文件名中有空格或换行符出现，find的-print0意思是以NULL作为文件名的结束符，而xargs -0是识别以NULL结束的文件名，此处-0的全称是--null）

    find . -type d -name ".svn"|xargs rm -rf （当某目录中包含空格时会删除不干净）
    find . -type d -name "*.svn" -exec rm -rf {} \;
    find . -type d -name ".svn" -printf "\"%p\"\n" | xargs rm -rf
    svn export src dest

最近版的SVN也和git一样了，只在根目录下生成了一个.svn目录，挺好。

### 文件链接

    硬链接不能链接目录，不能跨文件系统链接。
    软链接（符号链接）可以链接目录和跨文件系统链接。
    硬链接命令： ln src dest
    软链接命令： ln -s src dest
    （src表示已经存在的文件，dest表示将要创建的文件）

注：src和dest都应该用绝对路径，用相对路径的话会报Too many levels of symbolic links这种错误。

Both of these [types of links] provide a certain measure of dual reference -- if you edit the contents of the file using any name, your changes will affect both the original name and either a hard or soft new name. The differences between them occurs when you work at a higher level. The advantage of a hard link is that the new name is totally independent of the old name -- if you remove or rename the old name, that does not affect the hard link, which continues to point to the data while it would leave a soft link hanging pointing to the old name which is no longer there. The advantage of a soft link is that it can refer to a different file system (since it is just a reference to a file name, not to actual data). And, unlike a hard link, a symbolic link can refer to a directory.

### patch命令

    patch [options] [originalfile [patchfile]]
    # patch -pnum <patchfile
    options:
    -b or --backup #backup originalfile
    -pnum  or  --strip=num
    Strip the smallest prefix containing num leading slashes from each file name found in the patch file.
    /u/howard/src/blurfl/blurfl.c
    setting -p0 gives the entire file name unmodified, -p1 gives
    u/howard/src/blurfl/blurfl.c
    without the leading slash, -p4 gives
    blurfl/blurfl.c

### 给软件打补丁（patch）

    1. 假设软件源码包为：stunnel-4.32.tar.gz (ftp://ftp.stunnel.org/stunnel/obsolete/4.x/)
    2. 假设解压后的位置为：/home/zhiwei/stunnel-4.32
    3. 假设补丁文件位置为：/home/zhiwei/stunnel-4.32-xforwarded-for.diff (http://haproxy.1wt.eu/download/patches/)
    4. 假设当前目录为：/home/zhiwei/stunnel-4.32，则打补丁命令为：patch -p1 < ../stunnel-4.32-xforwarded-for.diff
    5. 补丁已经应用成功，可以重新安装：./configure;make;make install

### 编写脚本时需要注意的事项

    1. 有对目录进行操作的命令时先判断目录是否存在或者是否为空
    2. 脚本执行需要传递参数时先判断参数的合法性
    3. 对目录、文件进行删除、移动操作时先备份再仔细检查当目录或文件不存在或为空时的后果

### 机器重启后时间出现问题

    物理机：
    如果重启前后时间相差整点（小时）则很可能是时区设置问题，否则可以先升级固件（firmware），如果仍然有问题则再考虑软件。
    虚拟机：
    一般虚拟机都是出现整点误差，可以检查虚拟机时区的设置。

### 无交互式修改用户密码

    echo "123456 " | passwd --stdin root

还可以直接修改shadow文件，不建议哦。

### 设置随机启动：

    chkconfig --levels 3 httpd on
    chkconfig --list httpd
    httpd 0:off 1:off 2:off 3:on 4:off 5:off 6:off
    chkconfig --levels 3 mysqld on
    chkconfig --list mysqld
    mysqld 0:off 1:off 2:off 3:on 4:off 5:off 6:off

### 文件权限

    rwx
    s--SUID/SGID
    t--sticky位
    可以通过chmod g-s filename来取消SUID位

### Bash Shell中预定义的常量

    1. echo $HOSTTYPE 查看机器CPU类型（i386,i686,x86_64）
    2. echo $LANG 查看机器语言及编码（en_US.UTF-8）
    3. echo $BASH 查看当前Bash类型（/bin/bash,/bin/sh）
    4. echo $BASH_VERSION 查看bash版本（3.2.25(1)-release）
    5. echo $$ 查看当前bash的进程ID
    6. echo $MACHTYPE 查看机器类型machine type（x86_64-redhat-linux-gnu）
    7. echo $HOSTNAME 查看主机名
    8. echo $OSTYPE 查看操作系统类型（linux-gnu）
    9. echo $PATH 查看环境变量
    10. echo $LOGNAME 查看当前登录用户名
    11. echo $TERM 查看term类型（xterm）
    12. echo $RANDOM 产生随机整数
    13. 还有很多$PWD,$HISTFILE,$HISTCMD,$MAIL等，可以用 echo $ +tab tab 来查看所有的常量

### Shell脚本语言中test命令用法

先看一个命令：意思是测试当前目录下是否存在study文件（文件夹），若存在则输出exist!，否则输出not exist!

    # test -e study && echo "exist!" || echo "not exist!"

    以下是test命令常用的测试标志：
    1. 某文件名的类型检测（存在与否及文件类型）（test -e filename）
    -e :该“文件名”是否存在。 (exist)
    -d :该文件名是否为目录。 (directory)
    -f :该文件名是否为普通文件。 (file)
    b,c,S,p,L分别指的是块设备、字符设备、套接字文件、管道文件及链接文件。(block,character,socket,pipe,link)

    2. 文件权限的检测（test -r filename）
    -r :该文件是否具有可读属性 (read)
    -w :该文件是否具有可写属性 (write)
    -x :该文件是否具有可执行属性 (execute)
    -s :该文件是否为非空白文件 (space，即该文件内容均为空格组成但是至少要有一个空格)

    3. 比较两个文件（test file_a nt file_b）
    -nt :文件file_a是否比file_b新 (newer than)
    -ot :文件file_a是否比file_b旧 (older than)
    -ef :判断两个文件是否为同一文件，可用于判断硬连接。（主要判断两个文件是否均指向同一个inode）

    4. 两个整数之间的判断（test n1 -eq n2）
    -eq :两个数相等（equal）
    -ne :两个数不相等（not equal）
    -gt :前者大于后者（greater than）
    -lt :前者小于后者（less than）
    -ge :前者大于等后者 (greater or equal)
    -le :前者小于等于后者 (lower or equal)

    5. 判断字符串
    test -z str :判断字符串是否为空，若为空则回传true (zero)
    test -n str :判断字符串是否为非空，左路为非空则回传true（-n亦可省略）
    test str_a = str_b及test str_a != str_b:判断两字条串是否相等及不相等。


    6. 多重判断条件（test -r file -a -w file）
    -a :and，当两个条件都满足时才回传true，即file具有读和写权限
    -o : or，当两个条件满足其一时即回传true
    -! :条件求反，test -! -x file，即当file不具有执行权限时才回传true

### Shell中常见字串含义

    $$ 当前bash的进程号
    $!  获取上条命令执行的进程pid
    $# 获取参数个数
    $@ 获取参数列表 （$* 也是获取参数列表）
    $? 获取程序返回值（成功为0，错误为其他）
    ${#array[@]} 获取数组长度（元素个数），array为数组名
    ${array[*]}  获取数组元素列表
    ${#str}  获取字符串长度
    ${name:?error message} 检查一个变量是否存在

### MySQL启动与更改密码

安装好MySQL之后，先启动MySQL服务（service mysqld start 或 /etc/init.d/mysqld start）

为MySQL的root用户设置密码（mysqladmin -uroot password 123456）

修改密码命令（mysqladmin -uroot -p123456 password newpasswd）

change password in safe:

    # /etc/init.d/mysqld stop
    # mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
    # mysql -u root mysql
    mysql> UPDATE user SET Password=PASSWORD('newpassword') where USER='root';
    mysql> FLUSH PRIVILEGES;
    mysql> quit
