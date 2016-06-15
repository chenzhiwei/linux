# Confd 是个好东西

可以用 Confd 去监控 Etcd 里某个 directory 或 keys 的改动，然后生成相当的配置文件并重新 reload 一下服务。

举个例子：将 nginx 的监听端口作为一个 key 放在 Etcd 里，当这个 key 改变时就自动 reload nginx 。

## 安装部署步骤

### 下载 Confd

```
# wget https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64
# chmod +x confd-0.11.0-linux-amd64
```

### 生成 Confd 配置文件`/etc/confd/conf.d/nginx.toml`

```
[template]

# The name of the template that will be used to render the application's configuration file
# Confd will look in `/etc/conf.d/templates` for these files by default
src = "nginx.tmpl"

# The location to place the rendered configuration file
dest = "/etc/nginx/conf.d/app.conf"

# The etcd keys or directory to watch.  This is where the information to fill in
# the template will come from.
keys = [ "/nginx" ]

# File ownership and mode information
owner = "root"
mode = "0644"

# These are the commands that will be used to check whether the rendered config is
# valid and to reload the actual service once the new config is in place
check_cmd = "/usr/sbin/nginx -t"
reload_cmd = "/usr/sbin/service nginx reload"
```

### 生成 Confd 模板文件`/etc/confd/templates/nginx.tmpl`

```
server {
    listen {{ getv "/nginx/port" }};
    location / {
        index index.html;
        root  /usr/share/nginx/html/;
    }
}
```

### 给 `/nginx/port` 赋值

```
# etcdctl set /nginx/port 8080
```

### 启动 Confd

```
# ./confd-0.11.0-linux-amd64 -watch -backend etcd -node http://127.0.0.1:4001
```


## 使用 Confd

From the first command you will see that Nginx listens on 8080.

The second command is to set the key `/nginx/port` to 8000.

From the third command you will see that Nginx listens on 8000.

```
# netstat -tnlp | grep 8080 # will show nginx listen 8080 port
# etcdctl set /nginx/port 8000
# netstat -tnlp | grep 8000 # will show nginx listen 8000 port
```
