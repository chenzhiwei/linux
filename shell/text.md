# 文本操作

## 汉字正则

```
# 匹配汉字
grep -P '[^\x00-\x7F]' test.txt

# 匹配三到五个汉字
vim: /[^\x00-\x7F]\{3,5}
```

## 打印前5行内容

```
head -5 test.txt
head -n 5 test.txt

sed -n '1,5p' test.txt

awk 'NR<6' test.txt
```

## 打印第5行内容

```
sed -n '5p' test.txt

awk 'NR==5' test.txt
```

## 打印第3行到第5行内容

```
sed -n '3,5p' test.txt

awk 'NR>2 && NR<6' test.txt
```

## 跨行打印：打印第 3 行 和 5~7 行内容

```
sed -n '3p;5,7p' test.txt

awk 'NR==3 || (NR>4 && NR<8)' test.txt
```

## 打印奇偶行内容

```
# 打印奇数行内容
## NR 表示行号
$ awk 'NR%2!=0' test.txt
$ awk 'NR%2' test.txt

## i 为变量，未定义变量初始值为 0，对于字符运算，未定义变量初值为空字符串
## 读取第 1 行记录，进行模式匹配：i=!0（!表示取反）。! 右边是个布尔值，0 为假，非 0 为真，!0 就是真，因此 i=1，条件为真打印第一条记录。
## 读取第 2 行记录，进行模式匹配：i=!1（因为上次 i 的值由 0 变成了 1），条件为假不打印。
## 读取第 3 行记录，因为上次条件为假，i 恢复初值为 0，继续打印。以此类推...
## 上述运算并没有真正的判断记录，而是布尔值真假判断。
$ awk 'i=!i' test.txt

## m~np：m 表示起始行；~2 表示：步长
$ sed -n '1~2p' test.txt

## 先打印第 1 行，执行 n 命令读取当前行的下一行，放到模式空间，后面再没有打印模式空间行操作，所以只保存不打印，同等方式继续打印第 3 行。
$ sed -n '1,$p;n' test.txt
$ sed -n 'p;n' test.txt

# 打印偶数行内容
$ awk 'NR%2==0' test.txt
$ awk '!(NR%2)' test.txt
$ awk '!(i=!i)' test.txt
$ sed -n 'n;p' test.txt
$ sed -n '1~1p' test.txt
$ sed -n '1,$n;p' test.txt
```

## 打印最后5行内容

```
tail -n 5 test.txt
```

## 打印匹配行内容

```
# 打印以 "1" 开头的行内容
$ sed -n '/^1/p' test.txt
$ grep "^1" test.txt

# 打印不以 "1" 开头的行内容
$ sed -n '/1/!p' test.txt
$ grep -v "^1" test.txt

# 从匹配 "03" 行到第 5 行内容
$ sed -n '/03/,5p' test.txt

# 打印匹配 "03" 行 到匹配 "05" 行内容
$ sed -n '/03/,/05/p' test.txt
```
