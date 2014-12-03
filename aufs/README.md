# AuFS

AuFS 在第一个版本时是 Another Union File System，第二个版本时是 Advanced multi layered unification filesystem。最初设计参考了UnionFS，目标是提高可靠性和性能。

AuFS 可以让多个文件系统上的目录和文件合并到同一个目录下，即合并多个文件和目录到到一个目录下。分层级的，可以将多个文件系统上的目录合并到一个目录里，第一个目录可以认为是一层。

## Examples

### 理解AuFS的工作原理

```
# mkdir /tmp/aufs
# cd /tmp/aufs
# mkdir first second final
# echo test > first/test.txt
# echo xxxx > second/xxxx.txt
# mount -t aufs -o br=/tmp/aufs/second:/tmp/aufs/first none /tmp/aufs/final
# ls /tmp/aufs/final
test.txt  xxxx.txt
```

* -o options passed to the filesystem
* br branch, separated by colon(:), a branch is nothing but a directory on a system
* none don't have any device associate with it

默认情况下第一个branch（second）是可读写的，其他的都是只读的，也就是说对`/tmp/aufs/final`目录所做的任何操作都会体现在`/tmp/aufs/second`目录中。

由于branch中第一个目录是second，所以挂载后的final目录中的文件以second目录中的为准。

```
# cd /tmp/aufs
# echo update > final/test.txt
# cat first/test.txt
test
# cat final/test.txt
update
# cat second/test.txt
update
```

### 统一查看目录

很多时候，系统管理员会遇到多个用户的home目录存在于多个磁盘分区的多个主home目录下，下面就说一下怎样统一查看这些用户的home目录。

`/home`目录是`/dev/sda2`的挂载点，其下面有用户`user1`和`user2`的home目录；`/home1`目录是`/dev/sdb2`的挂载点，其下面有用户`user3`的home目录，现在要在同一个目录`common`下面管理所有用户的home目录。

```
# mount -t aufs -o br=/home=rw:/home1=rw -o udba=reval  none /common/
# ls -l /common/
drwxr-xr-x 39 user1 user1 4096 Mar 25 15:52 user1
drwxr-xr-x 26 user2 user2 4096 Mar 25 15:51 user2
drwxr-xr-x  2 user2 user3 4096 Mar 25 16:36 user3
```

udba 是 User's Directory Branch Access，意思是当用户直接对branch中的目录进行操作而不是通过AuFS操作时应该怎么做，它的值有如下几种：

* udba=none – With this option, the AuFS will be faster, but may show incorrect data, if the user created any files/directories without going through the AuFS.
* udba=reval – With this option, the AuFS will re-lookup the branches and update it. So any changes done on any directories within the branch, will be reflected in"/common".
* udba=notify – With this option, the AuFS will register for inotify for all the directories in the branches. This affects the performance of AuFS.

写着写着感觉着很没意思，还是看原文吧。

## Reference

Linux AuFS Examples: <http://www.thegeekstuff.com/2013/05/linux-aufs/>
