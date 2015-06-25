# PHP

## PHP添加多语言支持

PHP的多语言支持是使用gettext扩展来实现的。

示例PHP代码如下：

```
echo _('Hello, world!');
echo gettext('Hello, PHP!');
```

其中`_()`为`gettext()`的简写。

由PHP文件生成po及mo文件的命令如下：

```
# xgettext --output=zh.po --language=PHP test.php
# msgfmt --output-file=zh.mo zh.po
```

生成po文件后，需要手动打开该文件进行编辑，然后再生成mo文件，最终程序只需要mo文件。

最终目录结构如下：

```
./lang.php
./lang/zh_CN/LC_MESSAGES/zh.mo
```
