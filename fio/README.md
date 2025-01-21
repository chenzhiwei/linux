# fio

磁盘IO性能测试工具。

## 参数解释

* name, Job的名字，简单明了，比如4K顺序写可以命名为`write4K-seq`
* loops, Job运行多少轮，默认值为1
* numjobs, Job的并行数，默认值为1
* runtime, Job的运行时长，纯数值为秒，也可以带单位，如5m、1h等
* time_based, 保证Job按runtime时长运行，如果提前完成了文件读写则重复运行直到runtime时长
* start_delay, 各Job的启动延时，可以是数值或区间，当是区间时各Job随机从区间中取值，纯数值为秒，可以带单位
* ramp_time,
* directory, Job生成文件的目录，默认为当前目录
* direct, 取值为0或1，1表示不使用IO Buffer
* rw/readwrite, 可以是read, write, randread, randwrite, rw, randrw
* bs/blocksize, 块大小，可以是 8k, 32k, 256k, 4m 等
* size, 每个Job要写的文件大小
* ioengine, Linux下一般用libaio，此时必须direct=1
* group_reporting, 通常与numjobs一起使用
* iodepth, 异步ioengine情况下，单次提交的IO单元数
* iodepth_batch_submit, 多少IO单元一超提交
* iodepth_batch_complete_max, 一次读取的最大IO单元数

## 测试命令

* 顺序写吞吐量：

    ```
    fio --name=write_throughput --directory=/path/to \
        --ioengine=libaio --direct --rw=write \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=1M \
        --iodepth=64 --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

* 随机写IOPS：

    ```
    fio --name=write_iops --directory=/path/to \
        --ioengine=libaio --direct --rw=randwrite \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=4K \
        --iodepth=256 --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

* 顺序读吞吐量：

    ```
    fio --name=read_throughput --directory=/path/to \
        --ioengine=libaio --direct --rw=read \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=1M \
        --iodepth=64 --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

* 随机读IOPS：

    ```
    fio --name=read_iops --directory=/path/to \
        --ioengine=libaio --direct --rw=randread \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=4K \
        --iodepth=256 --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

* 测试裸盘写IOPS：

    ```
    fio --name=write_iops --filename=/dev/sdX --filesize=200G \
        --ioengine=libaio --direct --rw=randwrite \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --bs=4K \
        --iodepth=256 --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

使用Jobfile：

```
fio --output output.fio --output-format terse,json,json+,normal jobfile.conf
```

jobfile.conf:

以下测试所需磁盘空间128G，计算公式：16 numjobs * 2G size * 4 jobs

```
[global]
ioengine=libaio
direct
numjobs=16
group_reporting
ramp_time=2s
runtime=5m
size=2G
time_based

directory=/your/path

[write1M-seq-throughput]
bs=1M
iodepth=64
iodepth_batch_complete_max=64
iodepth_batch_submit=64
rw=write
new_group

[write4K-rand-iops]
bs=4K
iodepth=256
iodepth_batch_complete_max=256
iodepth_batch_submit=256
rw=randwrite
new_group

[read1M-seq-throughput]
bs=1M
iodepth=64
iodepth_batch_complete_max=64
iodepth_batch_submit=64
rw=read
new_group

[read4K-rand-iops]
bs=4K
iodepth=256
iodepth_batch_complete_max=256
iodepth_batch_submit=256
rw=randread
new_group
```
