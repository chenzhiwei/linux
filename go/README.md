# GO

喜欢使用 GO 。

## 静态链接 binary

```
# git clone https://github.com/docker/swarm.git
# cd swarm
# godep restore -v
# CGO_ENABLED=0 GOOS=linux go build -a -tags netgo -ldflags '-w' .
```
