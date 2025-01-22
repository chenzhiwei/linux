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
* group_reporting, 通常与numjobs一起使用，把jobfile中的所有job统一展示报告
* stonwall, 让jobfile中的job顺序执行
* iodepth, 异步ioengine情况下，单次提交的IO单元数
* iodepth_batch_submit, 多少IO单元一超提交
* iodepth_batch_complete_max, 一次读取的最大IO单元数

## 测试命令

* 顺序写吞吐量：

    ```
    fio --name=write_throughput --directory=/path/to \
        --ioengine=libaio --direct=1 --rw=write \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=1M \
        --iodepth=64 --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

* 随机写IOPS：

    ```
    fio --name=write_iops --directory=/path/to \
        --ioengine=libaio --direct=1 --rw=randwrite \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=4K \
        --iodepth=256 --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

* 顺序读吞吐量：

    ```
    fio --name=read_throughput --directory=/path/to \
        --ioengine=libaio --direct=1 --rw=read \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=1M \
        --iodepth=64 --iodepth_batch_submit=64 --iodepth_batch_complete_max=64
    ```

* 随机读IOPS：

    ```
    fio --name=read_iops --directory=/path/to \
        --ioengine=libaio --direct=1 --rw=randread \
        --numjobs=16 --time_based --runtime=5m --ramp_time=2s \
        --group_reporting --size=1G --bs=4K \
        --iodepth=256 --iodepth_batch_submit=256 --iodepth_batch_complete_max=256
    ```

* 测试裸盘写IOPS：

    通常filesize为/dev/sdX的大小。

    ```
    fio --name=write_iops --filename=/dev/sdX --filesize=200G \
        --ioengine=libaio --direct=1 --rw=randwrite \
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
direct=1
numjobs=16
stonewall
ramp_time=2s
runtime=5m
size=2G
time_based

directory=/your/path

[write1M-seq-throughput]
bs=1M
rw=write
iodepth=64
iodepth_batch_submit=64
iodepth_batch_complete_max=64

[write4K-rand-iops]
bs=4K
rw=randwrite
iodepth=256
iodepth_batch_submit=256
iodepth_batch_complete_max=256

[read1M-seq-throughput]
bs=1M
rw=read
iodepth=64
iodepth_batch_submit=64
iodepth_batch_complete_max=64

[read4K-rand-iops]
bs=4K
rw=randread
iodepth=256
iodepth_batch_submit=256
iodepth_batch_complete_max=256
```

## 结果解读

经过简单实测，发现如下：

* `numjobs`对测试结果几乎没影响。
* `iodepth`对结果影响还挺大的。

```
fio-3.36
Starting 16 processes
Jobs: 16 (f=16): [w(16)][100.0%][w=54.4MiB/s][w=13.9k IOPS][eta 00m:00s]
write_iops: (groupid=0, jobs=16): err= 0: pid=1442: Wed Jan 22 02:37:36 2025
  write: IOPS=13.9k, BW=54.4MiB/s (57.0MB/s)(6544MiB/120336msec); 0 zone resets
    slat (nsec): min=1313, max=665465, avg=6231.97, stdev=4049.74
    clat (msec): min=14, max=703, avg=294.59, stdev=110.11
     lat (msec): min=14, max=703, avg=294.60, stdev=110.11
    clat percentiles (msec):
     |  1.00th=[   19],  5.00th=[  107], 10.00th=[  146], 20.00th=[  201],
     | 30.00th=[  243], 40.00th=[  271], 50.00th=[  300], 60.00th=[  326],
     | 70.00th=[  355], 80.00th=[  384], 90.00th=[  439], 95.00th=[  477],
     | 99.00th=[  523], 99.50th=[  535], 99.90th=[  550], 99.95th=[  575],
     | 99.99th=[  676]
   bw (  KiB/s): min=34311, max=86368, per=100.00%, avg=55715.02, stdev=557.23, samples=3838
   iops        : min= 8577, max=21592, avg=13928.26, stdev=139.31, samples=3838
  lat (msec)   : 20=1.40%, 50=0.60%, 100=2.20%, 250=28.41%, 500=65.00%
  lat (msec)   : 750=2.62%
  cpu          : usr=0.24%, sys=0.46%, ctx=1093613, majf=0, minf=582
  IO depths    : 1=0.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=100.0%
     submit    : 0=0.0%, 4=99.5%, 8=0.5%, 16=0.1%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=99.5%, 8=0.5%, 16=0.1%, 32=0.0%, 64=0.0%, >=64=0.1%
     issued rwts: total=0,1671170,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=256

Run status group 0 (all jobs):
  WRITE: bw=54.4MiB/s (57.0MB/s), 54.4MiB/s-54.4MiB/s (57.0MB/s-57.0MB/s), io=6544MiB (6862MB), run=120336-120336msec

Disk stats (read/write):
  sdb: ios=51/1725211, sectors=2112/13801688, merge=0/0, ticks=5/499933890, in_queue=499933896, util=100.00%
```

以上为group_reporting后的结果。

* write_iops - Job名字
* **write - statistics result**
* slat - submission latency, the time it took to submit the I/O.
* clat - completion latency, the time from submission to completion of the I/O pieces.
* lat - total latency, the time from submission to completion of the I/O pieces.
* bw - bandwidth statistics
* iops - iops statistics
