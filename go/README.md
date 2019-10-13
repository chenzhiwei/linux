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

go mod tidy
```

然后开始写正常代码就行，接下来 go 就会把依赖放在 vendor 目录下，也不会再提 GOPATH 的事情了。

## 设置自己的 Go Import 地址

很多时候，很多平台说倒就倒了，或者自己想完全掌控自己的内容，所以就会把东西放在自己的域名下。

官方文档：https://golang.org/cmd/go/#hdr-Remote_import_paths

示例：

* Go Import: `k8s.io/api`
* Source Code: `https://github.com/kubernetes/api`
* Https Server URL: `https://k8s.io/api?go-get=1`

    ```
    <html>
      <head>
        <meta name="go-import"
            content="k8s.io/api
            git https://github.com/kubernetes/api">
        <meta name="go-source"
            content="k8s.io/api
            https://github.com/kubernetes/api
            https://github.com/kubernetes/api/tree/master{/dir}
            https://github.com/kubernetes/api/blob/master{/dir}/{file}#L{line}">
      </head>
    </html>
    ```
