# Python调用C/C++里的函数

## calculate.c

标准的C语言函数文件。

[calculate.c](calculate.c)

## calculate_module.c

C语言Python wrapper，python原生代码可以通过这个wrapper来调用C语言函数文件里的函数。

[calculate_module.c](calculate_module.c)

## wrapper的构成

包含三个部分：导出函数、方法列表和初始化函数。

## 编译链接

```
$ gcc -fpic -c -I /usr/include/python2.7 \
    -I /usr/lib/python2.7/config-x86_64-linux-gnu calculate_module.c
$ gcc -shared -o calculate.so calculate_module.o
```

## Python调用

```
$ python
> import calculate
> calculate.add(3, 4)
> calculate.square(5)
> calculate.message('Hello world!', 6)
```

## 参考链接

1. <http://www.ibm.com/developerworks/cn/linux/l-pythc/>
2. <https://docs.python.org/2.7/c-api/index.html>
3. <https://docs.python.org/2.7/extending/extending.html>
