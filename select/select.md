## python select网络编程详细介绍

刚看了反应堆模式的原理，特意复习了socket编程，本文主要介绍python的基本socket使用和select使用，主要用于了解socket通信过程

### 一、socket模块

socket — Low-level networking interface

This module provides access to the BSD socket interface. It is available on all modern Unix systems, Windows, MacOS, and probably additional platforms.

更多详细信息请看官方文档 https://docs.python.org/3/library/socket.html

1、Socket类型

|socket 常量 |  描述|
------------|------------------------------------------------------------------------------------------------------------
|socket.AF_UNIX | 只能够用于单一的Unix系统进程间通信|
|socket.AF_INET | 服务器之间网络通信|
|socket.AF_INET6 |IPv6|
|socket.SOCK_STREAM |流式socket , for TCP|
|socket.SOCK_DGRAM  |数据报式socket , for UDP|
|socket.SOCK_RAW |原始套接字，普通的套接字无法处理ICMP、IGMP等网络报文，而SOCK_RAW可以；其次，SOCK_RAW也可以处理特殊的IPv4报文；此外，利用原始套接字，可以通过IP_HDRINCL套接字选项由用户构造IP头。|
|socket.SOCK_SEQPACKET |可靠的连续数据包服务|
|创建TCP Socket： |s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)|
|创建UDP Socket： |s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)|

### 2、socket函数

#### 服务器端 Socket 函数

|Socket 函数	 | 描述|
|:------------------|:------------------------------------------------------------------------------------|
|s.bind(address) |	将套接字绑定到地址，在AF_INET下，以tuple(host, port)的方式传入，如s.bind((host, port))|
|s.listen(backlog) |	开始监听TCP传入连接，backlog指定在拒绝链接前，操作系统可以挂起的最大连接数，该值最少为1，大部分应用程序设为5就够用了|
|s.accpet() |	接受TCP链接并返回（conn, address），其中conn是新的套接字对象，可以用来接收和发送数据，address是链接客户端的地址。|

#### 客户端 Socket 函数

|Socket 函数	| 描述
------------|--------------------------------------------------------------------------------------------------------------
|s.connect(address) | 链接到address处的套接字，一般address的格式为tuple(host, port)，如果链接出错，则返回socket.error错误|
|s.connect_ex(address) |	功能与s.connect(address)相同，但成功返回0，失败返回errno的值|

#### 公共 Socket 函数

|Socket 函数	| 描述|
------------|------------------------------------------------------------------------------------------------------------
|s.recv(bufsize[, flag]) | 接受TCP套接字的数据，数据以字符串形式返回，buffsize指定要接受的最大数据量，flag提供有关消息的其他信息，通常可以忽略|
|s.send(string[, flag]) | 发送TCP数据，将字符串中的数据发送到链接的套接字，返回值是要发送的字节数量，该数量可能小于string的字节大小|
|s.sendall(string[, flag]) | 完整发送TCP数据，将字符串中的数据发送到链接的套接字，但在返回之前尝试发送所有数据。成功返回None，失败则抛出异常|
|s.recvfrom(bufsize[, flag]) | 接受UDP套接字的数据u，与recv()类似，但返回值是tuple(data, address)。其中data是包含接受数据的字符串，address是发送数据的套接字地址|
|s.sendto(string[, flag], address) | 发送UDP数据，将数据发送到套接字，address形式为tuple(ipaddr, port)，指定远程地址发送，返回值是发送的字节数|
|s.close() | 关闭套接字|
|s.getpeername() | 返回套接字的远程地址，返回值通常是一个tuple(ipaddr, port)|
|s.getsockname() | 返回套接字自己的地址，返回值通常是一个tuple(ipaddr, port)|
|s.setsockopt(level, optname, value) | 设置给定套接字选项的值|
|s.getsockopt(level, optname[, buflen]) | 返回套接字选项的值|
|s.settimeout(timeout) | 设置套接字操作的超时时间，timeout是一个浮点数，单位是秒，值为None则表示永远不会超时。一般超时期应在刚创建套接字时设置，因为他们可能用于连接的操作，如s.connect()|
|s.gettimeout() | 返回当前超时值，单位是秒，如果没有设置超时则返回None|
|s.fileno() | 返回套接字的文件描述|
|s.setblocking(flag) | 如果flag为0，则将套接字设置为非阻塞模式，否则将套接字设置为阻塞模式（默认值）。非阻塞模式下，如果调用recv()没有发现任何数据，或send()调用无法立即发送数据，那么将引起socket.error异常。|
|s.makefile() | 创建一个与该套接字相关的文件|

3、socket异常

|Exception | 解释|
------------|-------------------------------------------------------------|
|socket.error | 由Socket相关错误引发|
|socket.herror | 由地址相关错误引发|
|socket.gaierror |	由地址相关错误，如getaddrinfo()或getnameinfo()引发|
|socket.timeout |	当socket出现超时时引发。超时时间由settimeout()提前设定|
 
### 二、socket编程

#### 1、基于TCP（面向连接）的Socket编程(C++)
#### 服务器端顺序：
    (1. 加载套接字库
    (2. 创建套接字（serversocket）
    (3. 将套接字绑定到一个本地地址和端口上（bind）
    (4. 将套接字设为监听模式，准备接收客户请求（listen）
    (5. 等待客户请求的到来；当请求带来后，接受连接请求，返回一个新的对应于此次连接的套接字（accept）
    (6. 用返回的套接字和客户端进行通信（send/recv）调用socket类的getOutputStream()和getInputStream()获取输出流和输入流
    (7. 返回，等待另一个客户请求
    (8. 关闭套接字(closesocket)
 
#### 客户端程序：
    (1. 加载套接字库
    (2. 创建套接字(socket)
    (3. 向服务器发送连接请求（connect）
    (4. 和服务器端进行通信(send/receive) 调用socket类的getOutputStream()和getInputStream()获取输出流和输入流
    (5. 关闭套接字(closesocket)
 
#### 2、基于UDP（面向无连接）的socket编程(C++)
#### 服务器端（接收端）程序：
    (1. 加载套接字库
    (2. 创建套接字（socket）
    (3. 将套接字绑定到一个本地地址和端口上（bind）
    (4. 等待接收数据（recvfrom）
    (5. 关闭套接字(closesocket)
 
#### 客户端（发送端）程序
    (1. 加载套接字库
    (2. 创建套接字（socket）
    (3. 向服务器发送数据（sendto）
    (4. 关闭套接字(closesocket)

3、socket tcp 编程实例，c/s程序

#!/bin/env python                                                         
# -*- coding:utf8 -*-  
"""
server.py
"""                                                   
                                                                          
import socket                                                                              
                                                                          
host = ('10.1.32.80', 33333)                                              
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)   # 网络通信, TCP流 
s.bind(host)                                                              
s.listen(5)  # listen 5 client                                            
print "i'm waiting for connection..."                                     
                                                                          
while True:                                                               
    conn, addr = s.accept()   # connection  and ip address                
    print 'connected by', addr                                            
    while True:                                                           
        data = conn.recv(1024)                                            
        print "receive from %s:%s" % (addr, data)                         
        conn.sendall("server receive your messages, good bye.")           
        conn.close()                                                      
        break                                                             
# s.close()


#!/bin/env python                                                         
# -*- coding:utf8 -*-                                                     
                                                                          
import socket                                                             
"""                                                                       
client.py                                                                 
"""                                                                       
                                                                          
host = ('10.1.32.80', 33333)                                              
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)   # 网络通信, TCP流 
s.connect(host)                                                           
                                                                          
while True:                                                               
    msg = raw_input("Please input message: ")                             
    try:                                                                  
        s.sendall(msg)                                                    
    except socket.error:                                                  
        print "i'm die, bye bye~"                                         
        break                                                             
    data = s.recv(1024)                                                   
    print data                                                            
    if "good bye" in data:                                                
        break                                                             
s.close()

### 三、基于select的网络编程
#### 1、select介绍

   在python中，select函数是一个对底层操作系统的直接访问的接口。它用来监控sockets、files和pipes，等待IO完成（Waiting for I/O completion）。当有可读、可写或是异常事件产生时，select可以很容易的监控到。
  
   select.select（rlist, wlist, xlist[, timeout]） 传递三个参数，一个为输入而观察的文件对象列表，一个为输出而观察的文件对象列表和一个观察错误异常的文件列表。第四个是一个可选参数，表示超时秒数。其返回3个tuple，每个tuple都是一个准备好的对象列表，它和前边的参数是一样的顺序。

#### 2、使用select编程，聊天室程序如下。运行多个client，则可互相聊天，输入"exit"即可退出

服务器代码 selectserver.py

客户端代码 selectclient.py

### 四、多路IO复用介绍和区别
#### sellect、poll、epoll三者的区别（***多路IO复用都是同步的***）
##### select

   select最早于1983年出现在4.2BSD中，它通过一个select()系统调用来监视多个文件描述符的数组，当select()返回后，该数组中就绪的文件描述符便会被内核修改标志位，使得进程可以获得这些文件描述符从而进行后续的读写操作。
   
   select目前几乎在所有的平台上支持，其良好跨平台支持也是它的一个优点，事实上从现在看来，这也是它所剩不多的优点之一。
   
   select的一个缺点在于单个进程能够监视的文件描述符的数量存在最大限制，在Linux上 ***一般为1024*** ，不过可以通过修改 ***宏定义*** 甚至重新编译内核的方式提升这一限制。
   
   另外，***select()所维护的存储大量文件描述符的数据结构，随着文件描述符数量的增大，其复制的开销也线性增长***。同时，由于网络响应时间的延迟使得大量TCP连接处于非活跃状态，但调用 ***select()会对所有socket进行一次线性扫描*** ，所以这也浪费了一定的开销。
 
##### poll

   poll在1986年诞生于System V Release 3，它和select在本质上没有多大差别，但是 ***poll没有最大文件描述符数量的限制*** 。
   
   poll和select同样 ***存在一个缺点就是，包含大量文件描述符的数组被整体复制于用户态和内核的地址空间之间，而不论这些文件描述符是否就绪，它的开销随着文件描述符数量的增加而线性增大*** 。
   
   另外，select()和poll()将就绪的文件描述符告诉进程后，如果 ***进程没有对其进行IO操作，那么下次调用select()和poll()的时候将再次报告这些文件描述符，所以它们一般不会丢失就绪的消息，这种方式称为水平触发（Level Triggered）*** 。
 
##### epoll

   直到Linux2.6才出现了由内核直接支持的实现方法，那就是epoll，它几乎具备了之前所说的一切优点，被公认为Linux2.6下性能最好的多路I/O就绪通知方法。
   
   epoll可以* **同时支持水平触发和边缘触发（Edge Triggered，只告诉进程哪些文件描述符刚刚变为就绪状态，它只说一遍，如果我们没有采取行动，那么它将不会再次告知，这种方式称为边缘触发）*** ，理论上边缘触发的性能要更高一些，但是代码实现相当复杂。
 
   ***epoll同样只告知那些就绪的文件描述符，而且当我们调用epoll_wait()获得就绪文件描述符时，返回的不是实际的描述符，而是一个代表就绪描述符数量的值，你只需要去epoll指定的一个数组中依次取得相应数量的文件描述符即可，这里也使用了内存映射（mmap）技术，这样便彻底省掉了这些文件描述符在系统调用时复制的开销***。
 
   另一个本质的改进在于epoll采用基于事件的就绪通知方式。***在select/poll中，进程只有在调用一定的方法后，内核才对所有监视的文件描述符进行扫描，而epoll事先通过epoll_ctl()来注册一个文件描述符，一旦基于某个文件描述符就绪时，内核会采用类似callback的回调机制，迅速激活这个文件描述符，当进程调用epoll_wait()时便得到通知***。
