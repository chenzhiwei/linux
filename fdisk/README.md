# Format Disk

Use `fdisk` to increase the partition size.

```
fdisk /dev/sda

> d (delete a partition)
> 1 (input a partition number)
> n (new a partition)
> 1 (input a partition)
>  (enter)
>  (enter)
>  (enter)
> w (write to partition table)

resize2fs /dev/sda1
```
