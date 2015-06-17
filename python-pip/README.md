# Python pip

最开始 Python 打包非常不方便，安装之后也不知道都装了哪些内容，想要删除的话非常麻烦。

后来 Python 成立了个 pypa 就是 [Python Packaging Authority][pypa]。然后就有了 pip 以及优化扩展后的打包方式。

[pypa]: https://github.com/pypa

具体样例请看该目录下的`zenith`项目。

最开始我遇到一个很郁闷的事情，用`python setup.py install`安装时，代码也会安装在 EGG 目录中，一直没查到原因。后来用`pip install git+http://localhost/zenith.git`安装就会分开了，然后我也没详细查原因。
