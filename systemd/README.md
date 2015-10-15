# Systemd

System 是系统的意思，而 d 在 Linux 一般表示后台守护进程，又叫精灵进程（Daemon），而 systemd 就是系统守护进程，霸气十足。

## Linux init 系统

Init 系统用来启动系统所需的软件及程序，比如网络程序、图形界面程序等。一般还会有其他的服务，比如 SSHD 和打印机服务等等。

一般系统启动的步骤是：

* 打开硬件开关
* 进入 BIOS 引导
* Linux 内核 Bootloader
* Init 系统
* 服务程序/软件

而 systemd 就是一个新的 Init 系统，最早的名字就叫 Init，后来是 SysVinit，再后来出现了 Upstart，再往后就是 systemd 了。

SysVinit 有严格的启动顺序，在操作系统启动时 SysVinit 会按先后顺序去运行指定目录（/etc/rc*.d）下的脚本，进而启动各个服务。

Upstart 对 SysVinit 进行了优化，可以做到同时启动两个互不相关的服务，这样一来就提高了系统启动速度。比如 HTTPD 和 SSHD 互不相关，所以 Upstart 可以同时启动这两个服务进而减少启动时间。

Systemd 更激进一些，它可以同时启动任何多个服务，无论这些服务之间是否有关联。但是这需要程序本身对 Systemd 进行优化，否则单凭 Systemd 本身是无法做到同时启动任意多个服务的。

就我个人来说，我还是比较喜欢 SysVinit ，因为我的工作站是 Ubuntu 系统，平时工作用的也都是 Linux 系统，这些都是不需要经常重启的，所以 Systemd 的优势并不明显。况且 Systemd 是一个很大的 Binary ，将很多逻辑都封装进去了，总感觉不可靠。

## Systemd 服务配置文件

默认情况下，所有服务的 Systemd 配置文件都在`/usr/lib/systemd/system`目录下，你也可以将其放在`/etc/systemd/system`目录下，后者优先级比前者高，一般用来`override`前者。还有一个目录是`/run/systemd/system`一般用来存放临时文件的。

下面拿 Nginx 来举例说明其他目录：

* /usr/lib/systemd/system/nginx.service Nginx 的service unit 文件存放位置
* /etc/systemd/system/nginx.service.d/custom.conf 对 Nginx service unit 进行定制的文件，这里面的内容会 append 到上面的文件里。
* /etc/systemd/system/nginx.service.wants/* 启动 Nginx service 之后需要启动的东西。
* /etc/systemd/system/nginx.service.requires/* 启动 Nginx service 之前需要启动的东西。

## Systemd 的优点

* 可以并行启动服务，提高开机速度。
* 可以监控服务的状态，当出现故障时自动启动它们。
* 启动服务时可以自动启动其依赖的服务。
* 向下兼容 Init 脚本。

## Systemd 的缺点

* 当启动程序时无法进行交互。
* 感觉 Linux 服务器很少重启，加快启动速度没多大意义啊。

## Systemd Unit

这个 Unit 我也不知道准确的中文解释，就叫它单元吧。类型有 Service, Socket, Timer, Mount, Path 等等，不同的 Unit 文件，里面的内容区块是不同的。

拿 nginx.service 来举例，可以看出这个是 Service Unit ，其内容如下：

```
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=process
KillSignal=SIGQUIT
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

看到了吧，中间是`[Service]`，就表示这是个 Service Unit。

关于`[Unit]`，`[Service]`，`[Install]`应该怎么写其实已经有非常详细的 man 文档了，我这里再写出来感觉没啥意思。

用`man systemd.unit`来查看`[Unit]`和`[Install]`的写法，这两个是常规部分。

用`man systemd.service`来查看`[Service]`部分的写法，其它和这差不多。

## 最后

关于 Systemd 这东西真是让人又爱又恨，它可以管理很多事情，加快启动速度，但是却也让你无法内部工作原理。从目前来看，这货会是个趋势，所以尽早转换还是比较好的。
