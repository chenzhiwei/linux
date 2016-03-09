# NFS

## NFS(Network File System)

NFS能让使用者访问网络上其他主机的文件就像访问自己电脑上文件一样。NFS是基于UDP/IP协议的应用，其实现主要是采用RPC（Remote Procedure Call,远程过程调用）机制，PRC提供了一个与机器、操作系统以及低层传送协议无关的存取远程文件的操作。RPC采用了XDR的支持，XDR是一种与机器无关的数据描述编码协议，他以独立于任意机器体系结构的格式对网上传送的数据进行编码和解码，支持在异构系统之间数据的传送。

NFS在`/etc/fstab`里的简单配置如下：

```
nfs_server:/var/nfs /mnt  nfs   defaults    0 0
```

NFS的配置文件在`/etc/exports`里面，当修改之后需要用`exportfs -ar`命令来重新加载一下。

`no_root_squash` 一般在NFS文件系统上安装RPM包时会报`chown`之类的错误，添加这个参数之后就OK了。

## 当 umount 不掉时

```
# fuser -m /mnt
# fuser -k /mnt
# fuser -mk /mnt
```

第一条命令是查看哪些进程在使用，第二条命令是 kill 掉这样进程，第三条命令是两者一起用。
