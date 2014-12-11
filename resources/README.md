# 一些学习资源

## Linux

[Linux tips](linux.md)

## Guide to IP Layer Network Administration with Linux

可以当作字典来查询各种命令及应用场景，有事没事多看看。

Linux系统IP层网络管理指南： <http://linux-ip.net/html/index.html>

## GPG Howto document

GPG的中文使用文档，安全通信的必备神器。<http://www.gnupg.org/howtos/zh/index.html>

## Nginx开发从入门到精通

淘宝核心系统服务器平台组成员共同写： <http://tengine.taobao.org/book/index.html>

## Redis和Memcached的比较

以下几点是二者很明确的差别，可以根据自己需求来选择适合自己的。

* redis persists the entire dataset to disk  
* redis doesn't support LRU or any similar policy for handling overload  
* redis doesn't support CAS (check and set) which is useful for maintaining cache consistency  
* redis supports richer data structures other than plain strings and can operate on them internally. For example, you can intersect two sets and return the result.
* redis supports master/slave replication

如果以上几点不是你最关心的，那么你可以参考如下的对比测试：

最好你自己进行测试一下，因为这是以前低版本的测试数据。（注意：不要用虚拟机进行测试）

1. <http://systoilet.wordpress.com/2010/08/09/redis-vs-memcached/>
2. <http://oldblog.antirez.com/post/redis-memcached-benchmark.html>
3. <http://www.quora.com/What-are-the-differences-between-memcached-and-redis>
4. <https://chrome.google.com/webstore/detail/proxy-switchysharp/dpplabbmogkhghncfbfdeeokoefdjegm>
5. <https://github.com/chenzhiwei/linux/raw/master/resources/switchy.txt>
