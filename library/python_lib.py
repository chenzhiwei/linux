#!/usr/bin/env python

import httplib
import urllib2
import urllib, re

'''
url get usage
params = {'id':15}
url = http://localhost/index.php
print get(url, params)
'''
def get(url, params=None, headers={}):
    m = re.match("(http|https)://([a-zA-Z0-9\.-]+)(/.*|$)", url)
    scheme = m.group(1)
    host = m.group(2)
    uri = m.group(3)
    if params:
        # query = urllib.urlencode(params)
        query = ''
        for key in params.keys():
            query = query + '&' + key + '=' + str(params[key])

        query = query.lstrip('&')
        uri = uri + '?' + query

    try:
        if scheme == 'http':
            conn = httplib.HTTPConnection(host, timeout=5)
        else:
            conn = httplib.HTTPSConnection(host, timeout=5)
        conn.request('GET', uri, headers=headers)
        result = conn.getresponse()
        code = result.status
        content = result.read()
        conn.close()
    except Exception, e:
        code = 0
        content = 'get url exception!'
        print e

    return code, content

'''
url post usage
data = {'name':'testname'}
url = 'http://localhost/index.php'
print post(url, data)
'''
def post(url, params=None, headers={}):
    m = re.match("(http|https)://([a-zA-Z0-9\.-]+)(/.*|$)", url)
    scheme = m.group(1)
    host = m.group(2)
    uri = m.group(3)
    if params:
        data = urllib.urlencode(params)

    headers = {"Content-type": "application/x-www-form-urlencoded",
                "Accept": "text/plain"}

    try:
        if scheme == 'https':
            conn = httplib.HTTPSConnection(host, timeout=5)
        else:
            conn = httplib.HTTPConnection(host, timeout=5)
        conn.request('POST', uri, body=data, headers=headers)
        result = conn.getresponse()
        code = result.status
        content = result.read()
        conn.close()
    except Exception, e:
        code = 0
        content = 'post url exception!'
        print e

    return code, content

''' curl usage
GET Method: params = {'id':'aaa'}
POST Method: data = {'name':'bbb'}
HEADERS: header = {'Host':'abc.com'}
print curl('http://localhost/index.php', params, data, header)
'''
def curl(url, params=None, data=None, header={}):

    if params:
        param = ''
        for key in params.keys():
            param = param + '&' + key + '=' + str(params[key])

        param = param.lstrip('&')
        url = url + '?' + param

    if data:
        data = urllib.urlencode(data)

    # urllib2.socket.setdefaulttimeout(5)
    try:
        req = urllib2.Request(url, data, headers=header)
        fp = urllib2.urlopen(req, timeout=5)
        content = fp.read()
        code = fp.code
        fp.close()
    except urllib2.HTTPError, e:
        code = e.code
        content = e.msg
    except urllib2.URLError, e:
        code = 0
        content = e.reason

    return code, content

'''
mysql = MySQL('127.0.0.1', 'test', '123456', 'test')
sql = 'select * from test'
print mysql.get_data(sql)
mysql.conn_close()
'''
import MySQLdb
class MySQL:
    def __init__(self, db_host, db_user, db_pass, db_name,
            db_port=3306, db_sock='/tmp/mysql.sock', db_charset='latin1',
            db_connect_timeout=5):

        conn = None
        try:
            conn = MySQLdb.connect(db_host, db_user, db_pass, db_name, db_port,
                    db_sock, charset=db_charset, connect_timeout=db_connect_timeout)
        except Exception, e:
            print e
            exit(1)

        self.conn = conn

    def get_data(self, sql):
        cur = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cur.execute(sql)
        rows = cur.fetchall()
        cur.close()
        return rows

    def get_var(self, sql):
        cur = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cur.execute(sql)
        row = cur.fetchone()
        cur.close()
        return row

    def run_sql(self, sql):
        cur = self.conn.cursor()
        ret = cur.execute(sql)
        if ret:
            self.conn.commit()
            cur.close()
            return True
        else:
            cur.close()
            return False

    def conn_close(self):
        self.conn.close()
