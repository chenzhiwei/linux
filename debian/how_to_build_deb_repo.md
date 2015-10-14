# 怎样创建 deb 仓库

## 安装 reprepro

```
# apt-get install reprepro
```

## 创建配置文件

```
$ mkdir conf
$ vim conf/distributions
Origin: Apache Mesos
Label: Apache Mesos
Codename: trusty
Architectures: i386 amd64
Components: main
Description: Apache Mesos debian repository
# SignWith: yes
```

## 创建仓库

```
$ reprepro --outdir=/var/www/html/mesos_repo includedeb trusty /path/to/mesos_0.25.0-1_amd64.deb
```

然后将 HTTP Server 的 htdocs 目录指向`/var/www/html/mesos_repo`就可以了。

## 给 deb 包签名

这个以后再说吧。
