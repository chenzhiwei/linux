

Flask，webpy，Django都带着 WSGI server，当然性能都不好，自带的web server 更多的是测试用途。线上发布时，则使用高性能的 wsgi server或者是联合nginx做uwsgi 。
greenlet是一个轻量级的协程库。gevent是基于greenlet的网络库。
guincorn是支持wsgi协议的http server，gevent只是它支持的模式之一 ，是为了解决django、flask这些web框架自带wsgi server性能低下的问题。它的特点是与各个web框架结合紧密，部署特别方便。
gunicorn安装和使用
安装

pip install gunicorn
启动

gunicorn code:application
其中code就是指python程序代码code.py，application就是那个wsgi func的名字。这样运行的话， gunicorn 默认作为一个监听 127.0.0.1:8000 的web server，可以在本机通过： http://127.0.0.1:8000 访问。
设置监听端口

如果要通过网络访问，则需要绑定不同的地址（也可以同时设置监听端口）。
gunicorn -b 127.0.0.1:8080
使用多进程

在多核服务器上，为了支持更多的并发访问并充分利用资源，可以使用更多的 gunicorn 进程。
gunicorn -w 8 code:application
这样就可以启动8个进程同时处理HTTP请求，提高系统的使用效率及性能。
配合gevent

另外， gunicorn 默认使用同步阻塞的网络模型(-k sync)，对于大并发的访问可能表现不够好， 它还支持其它更好的模式，比如：gevent或meinheld。

# gevent
gunicorn -k gevent code:application

指定配置文件

以上设置还可以通过 -c 参数传入一个配置文件实现。
gunicorn - gun.conf code:application

# cat gun.conf
import os
bind = '127.0.0.1:5000'
workers = 4
backlog = 2048
worker_class = "sync"
debug = True
proc_name = 'gunicorn.proc'
pidfile = '/tmp/gunicorn.pid'
logfile = '/var/log/gunicorn/debug.log'
loglevel = 'debug'

关于gevent

gevent是一个基于libev的并发库。它为各种并发和网络相关的任务提供了整洁的API。gunicorn对于“协程”也就是Gevent的支持非常好。
gevent程序员指南：gevnet指南
gevent.monkey介绍详见：关于gevent monkey。
简单的Flask应用

Flask是一个轻量级的Web框架，核心简单而易于扩展。Flask介绍详见：Flask文档。
用Flask简单写了一个web例子，如下：

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello World!'

if __name__ == '__main__':
    app.run()

用gunicorn启动Flask应用
配置文件gun.py

import os
import gevent.monkey
gevent.monkey.patch_all()

import multiprocessing

debug = True
loglevel = 'debug'
bind = '0.0.0.0:8800'
pidfile = 'log/gunicorn.pid'
logfile = 'log/debug.log'

#启动的进程数
workers = multiprocessing.cpu_count() * 2 + 1 
worker_class = 'gunicorn.workers.ggevent.GeventWorker'

x_forwarded_for_header = 'X-FORWARDED-FOR'

使用gunicorn来启动

gunicorn -c gun.py hello:app

单纯的flask 自带的web服务器做下测试，会看到压力大的时候出现socket的问题，因为他是单进程单线程的。使用gunicorn来启动，响应速度和能力提升显著。 配置中workers指定启动的进程数。cpu的损耗是平均到各个进程。workers的值一定不要过大，毕竟多进程对于系统的调度消耗比较大。

来源：http://www.voidcn.com/blog/dutsoft/article/p-5977525.html
