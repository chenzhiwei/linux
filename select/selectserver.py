#!/bin/env python
#-*- coding:utf8 -*-

"""
server select
"""


import sys
import time
import socket
import select
import logging
import Queue


g_select_timeout = 10

class Server(object):
    def __init__(self, host='10.1.32.80', port=33333, timeout=2, client_nums=10):
        self.__host = host
        self.__port = port
        self.__timeout = timeout
        self.__client_nums = client_nums
        self.__buffer_size = 1024

        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.setblocking(False)
        self.server.settimeout(self.__timeout)
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1) #keepalive
        self.server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1) #端口复用
        server_host = (self.__host, self.__port)
        try:
            self.server.bind(server_host)
            self.server.listen(self.__client_nums)
        except:
            raise

        self.inputs = [self.server] #select 接收文件描述符列表  
        self.outputs = [] #输出文件描述符列表
        self.message_queues = {}#消息队列
        self.client_info = {}

    def run(self):
        while True:
            readable , writable , exceptional = select.select(self.inputs, self.outputs, self.inputs, g_select_timeout)
            if not (readable or writable or exceptional) :
                continue

            for s in readable :
                if s is self.server:#是客户端连接
                    connection, client_address = s.accept()
                    #print "connection", connection
                    print "%s connect." % str(client_address)
                    connection.setblocking(0) #非阻塞
                    self.inputs.append(connection) #客户端添加到inputs
                    self.client_info[connection] = str(client_address)
                    self.message_queues[connection] = Queue.Queue()  #每个客户端一个消息队列

                else:#是client, 数据发送过来
                    try:
                        data = s.recv(self.__buffer_size)
                    except:
                        err_msg = "Client Error!"
                        logging.error(err_msg)
                    if data :
                        #print data
                        data = "%s %s say: %s" % (time.strftime("%Y-%m-%d %H:%M:%S"), self.client_info[s], data)
                        self.message_queues[s].put(data) #队列添加消息 
                        
                        if s not in self.outputs: #要回复消息
                            self.outputs.append(s)
                    else: #客户端断开
                        #Interpret empty result as closed connection
                        print "Client:%s Close." % str(self.client_info[s])
                        if s in self.outputs :
                            self.outputs.remove(s)
                        self.inputs.remove(s)
                        s.close()
                        del self.message_queues[s]
                        del self.client_info[s]

            for s in writable: #outputs 有消息就要发出去了
                try:
                    next_msg = self.message_queues[s].get_nowait()  #非阻塞获取
                except Queue.Empty:
                    err_msg = "Output Queue is Empty!"
                    #g_logFd.writeFormatMsg(g_logFd.LEVEL_INFO, err_msg)
                    self.outputs.remove(s)
                except Exception, e:  #发送的时候客户端关闭了则会出现writable和readable同时有数据，会出现message_queues的keyerror
                    err_msg = "Send Data Error! ErrMsg:%s" % str(e)
                    logging.error(err_msg)
                    if s in self.outputs:
                        self.outputs.remove(s)
                else:
                    for cli in self.client_info: #发送给其他客户端
                        if cli is not s:
                            try:
                                cli.sendall(next_msg)
                            except Exception, e: #发送失败就关掉
                                err_msg = "Send Data to %s  Error! ErrMsg:%s" % (str(self.client_info[cli]), str(e))
                                logging.error(err_msg)
                                print "Client: %s Close Error." % str(self.client_info[cli])
                                if cli in self.inputs:
                                    self.inputs.remove(cli)
                                    cli.close()
                                if cli in self.outputs:
                                    self.outputs.remove(s)
                                if cli in self.message_queues:
                                    del self.message_queues[s]
                                del self.client_info[cli]

            for s in exceptional:
                logging.error("Client:%s Close Error." % str(self.client_info[cli]))
                if s in self.inputs:
                    self.inputs.remove(s)
                    s.close()
                if s in self.outputs:
                    self.outputs.remove(s)
                if s in self.message_queues:
                    del self.message_queues[s]
                del self.client_info[s]
        

if "__main__" == __name__:
    Server().run()
