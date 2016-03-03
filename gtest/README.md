# Google Test

一个不错的 C++ 测试框架，Mesos 用的就是它，以下是我在修复 Mesos 相关的 bug 时用到的东东。

## 只测试单个 test case

```
$ make check/test GTEST_FILTER="DecoderTest.Response"
$ ./libprocess-tests --gtest_filter="HTTPTest.StreamingGetFailure"
$ ./libprocess-tests --gtest_filter="HTTPTest.StreamingGetFailure" --verbose
$ ./libprocess-tests --gtest_filter="HTTPTest.StreamingGetFailure" --gtest_repeat=100 --verbose
```

* 第一个和第二个命令一样。
* 第三个命令输出更详细的信息。
* 第四个命令是重复运行这个 test case，有线程之间抢占资源时，运行单个是不会报错的，这时就需要多运行几次了。


## 调试

```
$ gdb --args ./libprocess-tests --gtest_filter="HTTPTest.StreamingGetFailure" --gtest_repeat=100
(gdb) b xxx.cpp:23
```


## Help

```
$ ./libprocess-tests --help
```
