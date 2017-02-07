# screen 命令简单用法

现在很多时候我们的开发环境都已经部署到云端了，直接通过SSH来登录到云端服务器进行开发测试以及运行各种命令，一旦网络中断，通过SSH运行的命令也会退出，这个发让人发疯的。

好在有screen命令，它可以解决这些问题。我使用screen命令已经有三年多的时间了，感觉还不错。

## 新建一个Screen Session

```
$ screen -S screen_session_name
```

## 将当前Screen Session放到后台

```
$ CTRL + A + D
```

## 唤起一个Screen Session

```
$ screen -r screen_session_name
```
##强制唤起一个Screen Session
```
$ screen -rd screen_session_name
```

## 分享一个Screen Session

```
$ screen -x screen_session_name
```

通常你想和别人分享你在终端里的操作时可以用此命令。

## 终止一个Screen Session

```
$ exit
$ CTRL + D
```

## screen进阶

对我来说，以上就足够了，有特定需求时再说。

## End

screen命令很好用，但是最让人头痛的是`CTRL+A`命令和BASH里的快捷键重复了，我不觉得替换一下快捷键是个很好的解决方案，所以这个问题一直存在我这里。
