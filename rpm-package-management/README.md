# RPM包管理相关

## RPM包相关工具

RPM包相关工具有rpm,rpmbuild,rpmsign,rpm2cpio等。

### rpm命令

```
# rpm -ihv name.rpm
# rpm -ql name.rpm
# rpm -qf /etc/keepalived/keepalived.conf
# rpm -qa
# rpm -qa php
# rpm -qa php*
# rpm --showrc # 查看所有RPM预设值
# rpm -E %configure # 查看RPM flag的值
# rpm -E %_lib
# rpm -E %_libdir
# rpm -E %_prefix
```

### rpmbuld命令

```
# rpmbuild -bb keepalived.spec
# rpmbuild -ba keepalvied.spec
# rpmbuild --rebuild keepalived-1.2.7-1.src.rpm
# rpmbuild --recompile keepalived-1.2.7-1.src.rpm
```

第一条命令只生成RPM包，第二条命令还会生成SRPM包，第三条命令将SRPM包生成RPM包，第四条是生成未打包的二进制文件。

先记住一个查看SPEC文件宏定义值的命令，然后再去记和签名相关的命令。另外，这些宏都定义在/usr/lib/rpm/macros文件中。

注： 该文件`~/.rpmmacros`会重写系统定义的macros文件。

### rpm2cpio命令

```
# rpm2cpio httpd-2.2.3-63.el5.centos.x86_64.rpm > httpd.cpio
# cpio -idmv < httpd.cpio
# rpm2cpio httpd-2.2.3-63.el5.centos.x86_64.rpm > httpd.cpio | cpio -idmv
```

将rpm转换成cpio格式，然后再解压出来。

## RPM包的简单介绍

正好我要打一个keepalived的RPM包，就拿这个来讲一下。

常见的RPM包名字格式是`keepalived-1.2.7-1.x86_64.rpm`，其中keepalived为包名，1.2.7为版本，1是发行标记，x86\_64是体系结构。有些RPM包的发行标记比较长，比如`httpd-2.2.3-63.el5.centos.x86_64.rpm`。

体系结构是RPM可以安装的系统平台，常见的有i386, i686, x86\_64, noarch，不常见的有ppc64, ia64, sparc64（感兴趣可以自己去查一下这些不常用的是什么意思）。

RPM包中只能看到头部（SPEC Header）和脚本（Scripts）信息，其他的都看不到。相关命令如下：

```
# rpm -i -qp keepalived-1.2.7-1.x86_64.rpm
# rpm --info -qp keepalived-1.2.7-1.x86_64.rpm
# rpm --scripts -qp keepalived-1.2.7-1.x86_64.rpm
```

其实还有一类RPM包，名字格式是`keepalived-1.2.7-1.src.rpm`，称它为SRPM，里面有RPM包的源码、SPEC文件及相关补丁。

这个目录下也有很多你需要的东西： /usr/share/doc/rpm-xxx/

## SPEC文件详解

SPEC文件有以下几个段落：头部（Header），准备（Prep），构建（Build），安装（Install），文件（Files），脚本（Scripts），变更记录（Changelog）。

* Summary 程序的摘要说明。

* Name 程序的名称。

* Version 程序的版本。

* Release 打包发行标记（修订版本）。

* License 许可方式。

* Group 程序所属的组，可选字段在`/usr/share/doc/rpm-xxx/GROUPS`文件中。

* URL 程序的官方站点什么的。（可选）

* Source\[0-n\] 程序的源码包位置，可以有多个，如Source, Source0, Source1。

* Patch\[0-n\] 程序的补丁文件位置。（可选）

* BuildRoot 程序虚拟目录树（fakeroot）的位置，可以用SHELL变量$RPM\_BUILD\_ROOT来获取。

* BuildArch 体系结构（CPU），常用的有i386, i686, x86\_64, noach。（可选，默认为`uname -m`）

* BuildRequires 编译程序时所依赖的软件。（可选，但是如果依赖的软件未安装会打包失败）

* Requires 程序运行时所依赖的软件。（可选，但是如果依赖软件未安装程序则无法运行）

* Requires(pre/post/preun/postun) 你懂的，不解释。

还有Vendor, Distribution, Icon, Packager, Serial, Provides, Conflicts, Autoreq, Autoprov, Autoreqprov, Exclusivearch, Excludeos等。哥，这实在太多了，我不想写了。

* %description 程序的详细说明，可以是一个或多个段落。

* %prep 是准备（Prep）段落的开始。

通常是构建（Build）前的准备工作，如解压源码、应用补丁等。该段落常用的宏是`%setup`意思是解压源码。该段落也可以用标准的Shell命令来完成，但是推荐用预定义的宏。

* %setup 解压源码包，解压后的目录默认是`%{name}-%{version}`，如果你的目录比较特殊，需要用`%setup -qn dirname`指定，其中-q意为quiet。（源码包为name-1.0.tar.gz，解压后的目录为name，此时需要-n来指定）

* %patch 示例`%patch -p 1 -b .bak`，不解释，自己看`patch`命令用法去。

* %build 构建段落的开始。一般常用`%configure`和`%{__make}`，可以用`rpm -E`来查看二者的值，可以用Shell命令来完成。

* %install 安装段落的开始。一般是安装二进制程序（`%{__make} install DESTDIR=%{buildroot}`）及其他相关工作（如先清空目的目录防止有脏文件）。

* %pre/post/preun/postun 安装前后、卸载前后要执行的命令。

之前我们有个需求是要修改某台httpd的mod\_headers.so模块，就重新打了个RPM包，然后安装时出错，提示文件冲突（httpd中已经有该文件了），当时我就用的post段落来解决的。即打包的模块名为mod\_headers.so.replace，%post段落执行备份mod\_header.so并用mod\_headers.so替换，%postun段落执行还原操作。

* %file 文件段落开始。

* %defattr(-, root, root, 0755) 来定义之后文件的相关属性。

* %attr(0600, root, root) %config(noreplace) %{\_sysconfdir}/keepalived/keepalived.conf 来单独定义某个文件的特殊属性。

* %config(noreplace) 意思是安装RPM时不覆盖旧的文件（如果旧文件存在的话），通常配置文件需要用此选项。

* %changelog 该段落的格式如下：

\* 日期 打包人 \<电子邮箱\> 版本-发行标记，其中日期格式为`date +"%a %b %d %Y"`，示例如下：

```
* Sat Dec 22 2012 Chen Zhiwei <zhiweik@gmail.com> 1.2.7-1
- First time to build keepalived package
- Happy begining and success ending
```
* %xxxx 还有其他N多个宏，这个不多说了。

比如`%check`段落，你可以检查一下额外的东东，如果不符合则你可以直接在该段落中有Shell的exit来退出。

还有其他的%veryfiscript, %triggerin, %triggerun, %triggerpostun等等段落，都可以用标准Shell来编写。

最后讲一下，你也可以用`%define`来预定义宏，如`%define __packager zhiwei`，那么就可以在SPEC文件的其他地方来引用了。

## 给RPM包签名

用PGP和GPG为RPM包签名，相关命令如下：

```
# echo "%_signature gpg" >> $HOME/.rpmmacros
# echo "%_gpg_name zhiweik@gmail.com" >> $HOME/.rpmmacros
# echo "%_gpg_path $HOME/.gnupg" >> $HOME/.rpmmacros
# rpmsign --addsign /usr/src/redhat/RPMS/x86_64/keepalived-1.2.7-1.x86_64.rpm
# gpg --export --armor > zhiwei-gpg-pub-key
# rpmsign --import /path/to/zhiwei-gpg-pub-key
# rpmsign -K keepalived-1.2.7-1.x86_64.rpm
```

以上几行命令的意思是：

1.以gpg方式来生成RPM包签名

2.指定用zhiweik@gmail.com这个密钥来签名打包

3.告诉rpmsign怎样定位你的gpg密钥

4.为keepalived包添加签名

5.导出你的gpg公钥

6.将你的公钥给安装keepalived的用户并让其导入

7.让用户来验证软件包签名是否正常

## 问题

* Found ‘${BUILDROOT}’ in installed files; aborting

    在`%install`部分最上面添加`rm -rf %{buildroot}`来解决。

## 吐槽

rpmbuild工具会自动帮你完成很多工作，而很多时候这些工作会影响你的打包，因此你可以关闭他们。

```
%define debug_package %{nil}
AutoReq: 0
AutoProv: 0
AutoReqProv: 0
```

除了这些你还会遇到其他各种各样的东西，例如java中的jar repack（`%define __jar_repack %{nil}`）。

## 最后的话

看了以上这些之后，我相信你肯定已经学会了RPM打包。当然了，在打包过程中你会遇到各种各样让人蛋疼的事情，不过你都可以解决这些问题的。

打包时可以看一下每一步的输出，有助于你深入理解RPM打包原理及解决你在打包时遇到的问题。

## 引用

* <http://www.rpm.org/max-rpm/>
