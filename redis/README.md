# Redis

## Redis cluster mode

Put the `redis` directory under `/etc` directory.

Start Redis instances:

```
docker run --name=redis7001 --net=host -d -v /etc/redis:/etc/redis redis:3.2.1 redis-server /etc/redis/7001/redis.conf
...
docker run --name=redis7006 --net=host -d -v /etc/redis:/etc/redis redis:3.2.1 redis-server /etc/redis/7006/redis.conf
```

Create a Redis cluster by using above instances:

```
docker run --rm -it siji/redis:cluster-tool sh
rcm -a redis321 create 192.168.122.20:7001 192.168.122.20:7002 192.168.122.20:7003 192.168.122.20:7004 192.168.122.20:7005 192.168.122.20:7006
```

If you want to disable authentication, you can remove the `requirepass redis321` in all `redis.conf` files, and run:

```
docker run --rm -it siji/redis:cluster-tool sh
rcm create 192.168.122.20:7001 192.168.122.20:7002 192.168.122.20:7003 192.168.122.20:7004 192.168.122.20:7005 192.168.122.20:7006
```

or

```
docker run --rm -it siji/redis:cluster-tool sh
redis-trib.rb create --replicas 1 192.168.122.20:7001:redis321 192.168.122.20:7002 192.168.122.20:7003 192.168.122.20:7004 192.168.122.20:7005 192.168.122.20:7006
```

Then using following command to connect:

```
redis-cli -c -h 192.168.122.20 -p 7001
```
