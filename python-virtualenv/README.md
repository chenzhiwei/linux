# Python Virtual Environment

这个东西比较好，方便用来开发并且不会破坏系统现有的依赖。

会在你机器上指定目录下创建一套虚拟的 Python 开发环境，你可以随意的安装、卸载 Python 包，使用非常方便。

这个东西和 Ruby 的 bundle 有点像，我很喜欢。


## 用法

### 创建环境

```
$ pip install virtualenv
$ vitualenv .venv
$ source .venv/bin/activate
$ type python
$ type pip
$ pip install six
$ ls .venv/lib/python/site-packages/six..
```

然后你使用的 pip 和 python 命令就是虚拟环境里的了，你可以去用它们来做各种操作而不去担心破坏自己操作系统的依赖了。


## 退出Python虚拟环境

```
$ deactivate
```
