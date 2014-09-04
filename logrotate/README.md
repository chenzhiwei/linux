# logrotate

logrotate是一个强大的日志备份工具，当某文件超过指定大小时就对其进行裁断备份。

logrotate的功能是管理记录文件。使用logrotate指令可以轻松管理系统产生的记录文件。它提供自动替换、压缩、删除和邮寄记录文件，每个记录文件都可被设置成每日、每周或每月处理，也能在文件太大时立即处理。这需要我们自行编辑配置文件，指定配置文件，设置配置文件在/etc/logrotate.conf

默认配置文件：/etc/logrotate.conf

自定义配置文件(默认配置文件中有include字段)：/etc/logrotate.d/*

调试某配置文件是否有语法错误：logrotate -d /etc/logrotate.d/logs

格式：

```
"/var/log/define_*.log" {
    daily (monthly,weekly，表示每天执行一次)
    dateext (在备份日志后加日志如：define_a.log-20110606)
    rotate 10 (轮转10个，即保留10个备份)
    missingok (当日志文件不存在时也不报错)
    notifempty (如果是空刚不转储，ifempty是空文件也转储)
    copytruncate (是指进行轮转时先把日志内容复制到新文件再清空旧文件，保证日志记录连续性)
    compress (nocompress,对轮转的日志文件进行压缩)
    sharedscripts ()
    postrotate (插入脚本前间隔段，指转储后要执行的命令；prerotate指转储前要执行的命令)
    /bin/bash /home/zhiwei/script.sh > /dev/null 2>&1
    endscript (插入脚本后间隔段)
    create 0644 owner group (轮转文件时使用指定模式和用户及用户组来创建新的日志文件)
    size 1024M (当日志文件达到1024M时才转储)
    olddir /backup (指定将备份后的文件放置位置)
}
```
