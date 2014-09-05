# Python调用C/C++里的函数

Python调用C语言的函数主要分为三部分：标准的C语言函数库、C语言Python调用模块(wrapper)、和标准的Python调用。

## 标准C语言函数库

里面有一系列的C语言函数。

```c
int add(int m, int n)
{
    return m + n;
}
```

[calculate.c](calculate.c)

## 标准Python调用

```
$ python
> import calculate
> calculate.add(3, 4)
```

## C语言Python调用模块

C语言Python wrapper，python原生代码可以通过这个wrapper来调用C语言函数文件里的函数。

这个模块分为三部分：导出函数、方法列表和初始化函数。

```c
/* Exported function */
static
PyCal_add(PyObject *self, PyObject *args)
{
    /* Define variables */
    int m, n;
    int ret;
    PyObject *obj;

    /* Parse Python args to C args */
    PyArg_ParseTuple(args, "ii", &m, &n);

    /* Call C native function */
    ret = add(m, n);

    /* Convert C variable to Python */
    obj = Py_BuildValue("i", ret);

    /* Return (converted)Python Object */
    return obj;
}

/* Method list */
static PyMethodDef CalMethods[] = {
    {"add", PyCal_add, METH_VARARGS, "Add two integer values."},
    {NULL, NULL, 0, NULL}
};

/* Initialization function */
PyMODINIT_FUNC
initcalcalate(void)
{
    PyObject *m;
    m = Py_InitModule("calculate", CalMethods);
    if(m == NULL) {
        return;
    }
}
```

### 导出函数

连接C语言函数和Python函数的中间件，由它来进行相互转换。把Python的参数转成C的参数传递过去，然后再把C的输出转换成Python格式返回。

* 转换Python参数为C语言类型

该函数的第二个参数`args`就是原生Python调用传递过来的参数，是一个C的Python Tuple Object，需要转换成标准的C语言数据类型。简单的参数可以使用`PyArg_ParseTuple`函数来进行解析，其中第二个参数是C语言中的[类型表示符][c-type-symbol]，示例中的意思是这个Python传过来的参数包含两个整型（int）数值并且分别赋值给m和n。

复杂点的参数就需要用`PyTuple_GetItem`进行解析了，比如args分别包含了一个int型和一个字典类型数据就需要如下操作：

```
int m;
PyObject *dict = NULL;
PyObject int_m = NULL;  /* int_m is a PyInt_Type */

int_m = PyTuple_GetItem(args, 0);
m = PyInt_AsLong(int_m);

dict = PyTuple_GetItem(args, 1);
```

此处的PyObject dict又可以使用PyDict_GetItemString(dict, key)来解析，如果这个dict的key不是字符串，可以使用PyDict_GetItem(dict, PyObjectKey)。

* 转换C语言数据为Python类型并返回

简单的C语言数据可以使用`Py_BuildValue`来转换，示例中`obj = Py_BuildValue("i", ret)`意思就是将ret转换成Python的int Object。

复杂的（比如返回值类型是list）可以用`PyList_SetItem`来转换，如这个返回的list中第一个值是字符串第二个是dict：

```c
PyObject *list = NULL;
PyObject *dict = NULL;

PyDict_SetItemString(dict, 'key', PyObjectValue);
PyList_SetItem(list, 0, PyObjectStringValue);   /* use PyString_FromString to
                                                   convert c string to python String */
PyList_SetItem(list, 1, dict);

return list;
```

[calculate_module.c](calculate_module.c)

[在ParseTuple和Py_BuildValue中可以使用的C类型][c-type-symbol]

[Python的类型怎样和C的映射][python-object-type]

[c-type-symbol]: https://docs.python.org/2.7/c-api/arg.html
[python-object-type]: https://docs.python.org/2.7/c-api/concrete.html

### 方法列表和初始化函数

你C函数库中所有函数都需要写到这里面，如下：

```c
static PyMethodDef CalMethods[] = {
    {"add", PyCal_add, METH_VARARGS, "Add two integer values."},
    {"square", PyCal_square, METH_VARARGS, "Square one integer value."},
    /* ... */
    {NULL, NULL, 0, NULL}
};
```

[参考](https://docs.python.org/2.7/extending/extending.html#the-module-s-method-table-and-initialization-function)

## 编译链接

```
$ gcc -fpic -c -I /usr/include/python2.7 \
    -I /usr/lib/python2.7/config-x86_64-linux-gnu calculate_module.c
$ gcc -shared -o calculate.so calculate_module.o
$ python
> import calculate
> calculate.add(3, 4)
```

gdb默认优化了编译选项，这会导致你调试时出现行号不对的问题，这时你需要在gcc编译时加上`-O0`来禁用优化来保证调试时行号与源文件保持一致。

## gdb调试python脚本及c module

```
# gdb python
(gdb) b PyCal_add
(gdb) dir /path/to/caculate_module_dir
(gdb) run test.py
(gdb) l
(gdb) n
(gdb) n
(gdb) p xx
```

## 参考链接

1. <http://www.ibm.com/developerworks/cn/linux/l-pythc/>
2. <https://docs.python.org/2.7/c-api/index.html>
3. <https://docs.python.org/2.7/extending/index.html>
