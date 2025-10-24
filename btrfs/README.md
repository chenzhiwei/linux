# Btrfs

Btrfs 也被称为「Better FS」、「Butter FS」、「B-tree FS」，是一个基于COW（Copy on Write）的支持逻辑卷管理的文件系统。

它可以做到 LVM 和 Raid 的功能，非常适合个人用户使用，比如我的笔记本电脑安装的 Arch Linux 就是使用的 Btrfs 文件系统，打快照什么的非常方便。

支持的Raid级别有：RAID 0, RAID 1, RAID 10, RAID 5 and RAID 6

## 基础使用

* 格式化一块盘或分区

    ```
    mkfs.btrfs -L mylabel /dev/disk0
    mkfs.btrfs -L mylabel /dev/nvme0n1p1
    ```

* 查看 Btrfs 磁盘或分区

    ```
    btrfs device scan
    ```

* 挂载 Btrfs

    以`zstd`压缩算法挂载。

    ```
    mount -t btrfs -o compress=zstd /dev/nvme0n1p1 /data
    ```

* 创建子卷

    注意：创建子卷前必须挂载分区。子卷名字加上`@`是便于区分子卷和原生目录。

    ```
    btrfs subvolume create /data/@home
    btrfs subvolume create /data/@audio /data/@video
    ```

* 查看子卷

    ```
    btrfs subvolume list -ta /data

    ID	gen	top level	path
    --	---	---------	----
    256	45641	5		@video
    ```

* 启用配额机制

    ```
    btrfs quota enable /mnt
    ```

* 查看配额信息

    ```
    btrfs qgroup show /data

    Qgroupid    Referenced    Exclusive   Path
    --------    ----------    ---------   ----
    0/5          174.54GiB    174.54GiB   <toplevel>
    0/256         16.00KiB     16.00KiB   @video
    ```

* 给子卷设置配额

    ```
    btrfs qgroup limit 10G 0/256 /data
    ```

* 查看子卷配额

    ```
    btrfs subvolume show /data/@video
    ```

* 挂载子卷

    ```
    mount -t btrfs -o subvol=/@video,compress=zstd /dev/nvme0n1p1 /video
    ```

* 自动挂载

    将如下内容放入`/etc/fstab`中，可通过`blkid`来获取`UUID`。

    ```
    UUID=</dev/nvme0n1p1 uuid> /video btrfs defaults,compress=zstd,subvol=/@video 0 0
    ```

## 高级用法 Raid

* 格式化

    下面的意思是元数据用`raid1`也就是存两份，数据存一份。

    ```
    mkfs.btrfs -m raid1 -d single /dev/nvme0 /dev/nvme1
    ```
