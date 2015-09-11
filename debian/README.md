# 怎样打包

Debian 包分两类，一类是源码包，另一类是二进制包。分别是从源码打包成 .deb 包，从二进制文件打包成 .deb 包。

## 从源码打包

从源码打包时，目录名叫作`debian`，里面主要的文件有`control`，`copyright`，`changelog`，`rules`等。

相关内容参考该目录下的相关文件。

```
$ git clone https://github.com/apache/mesos
$ cd mesos
$ cp -r debian .
$ dpkg-buildpackage -us -uc
```

NOTE: `dpkg-buildpackage -us -uc` will do everything to make full binary and source packages for you. It will:

* clean the source tree (**debian/rules clean**)
* build the source package (**dpkg-source -b**)
* build the program (**debian/rules build**)
* build binary packages (**fakeroot debian/rules binary**)
* make the .dsc file
* make the .changes file, using dpkg-genchanges

If the build result is satisfactory one, sign the .dsc and .changes files with your private GPG key using the debsign command. You need to enter your secret pass phrase, twice.

## 从二进制文件打包

从预编译好的二进制文件打包时，目录名叫作`DEBIAN`，里面主要的文件有`control`。


## 引用

* <https://www.debian.org/doc/manuals/maint-guide/index.en.html>
* <https://www.debian.org/doc/manuals/maint-guide/dreq.en.html#rules>
