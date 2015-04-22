# 搭建 pypi 镜像

简单几步，更多用法请看文档：<https://github.com/wolever/pip2pi>

## 下载包

```
# pip2tgz packages/ foo==1.2
# pip2tgz packages/ -r requirements.txt
```

## 创建索引

```
# dir2pi packages/
```

## 创建 Web Server

Web root 目录指向 `packages/simple`
