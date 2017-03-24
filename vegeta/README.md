# Vegeta

## 单台机器压测

```
echo "GET http://localhost/index.html" | vegeta attack -rate=1000 -duration=120s > result.bin
vegeta report -inputs=result.bin
```

## 多台机器压测

同步机器的时间：

```
pdsh -R ssh -l root -b -w "10.0.0.10,10.0.0.11,10.0.0.12" 'ntpdate 0.pool.ntp.org'
pdsh -R ssh -l root -b -w "10.0.0.10,10.0.0.11,10.0.0.12" 'date +%s'
```

开始测试：

```
pdsh -R ssh -l root -b -w "10.0.0.10,10.0.0.11,10.0.0.12" 'echo "GET htt://10.1.0.12/index.html" | vegeta attack -rate=1000 -duration=120s > result.bin'
for host in 10.0.0.10 10.0.0.11 10.0.0.12; do scp $host:~/result.bin $host; done
vegeta report -inputs=10.0.0.10,10.0.0.11,10.0.0.12
```

## Vegeta

https://github.com/tsenart/vegeta

## pdsh

```
./configure --with-ssh
make
make install
```

https://github.com/grondo/pdsh
