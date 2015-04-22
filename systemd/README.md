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

默认情况下，所有服务的 Systemd 配置文件都在`/usr/lib/systemd/system`目录下，你也可以将其放在`/etc/systemd/system`目录下，后者优先级比前者高，一般用来`override`前者。
