# GO

喜欢使用 GO 。

## 静态链接 binary

```
# git clone https://github.com/docker/swarm.git
# cd swarm
# godep restore -v
# CGO_ENABLED=0 GOOS=linux go build -a -tags netgo -ldflags '-w' .
```

另一种方法编译静态链接 binary

```
# GOPATH=~/go CGO_ENABLED=0 GOOS=linux go get -a -tags netgo -ldflags '-w' github.com/docker/swarm
```

某些项目里还可以去掉`CGO_ENABLED=0 GOOS=linux`这个东西。


## 跨平台编译

GO 的强大之处还有就是跨平台编译，你可以在`x86_64`上编译出来`ppc64le`的二进制文件。

```
$ GOPATH=~/go GOARCH=ppc64le GOOS=linux go get -a -tags netgo -ldflags '-w' github.com/docker/swarm
```

## Go Modules

Go 语言最奇帕的地方终于改进了，把源码放在 GOPATH 里导致的问题实在太多了，从 Go 1.11 开始终于改进了。

使用方法如下：

```
mkdir project
cd project
go mod init github.com/chenzhiwei/project
```

然后开始写正常代码就行，接下来 go 就会把依赖放在 vendor 目录下，也不会再提 GOPATH 的事情了。
