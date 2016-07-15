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
