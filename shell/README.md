# Shell

### Bash Shell中预定义的常量

    1. echo $HOSTTYPE 查看机器CPU类型（i386,i686,x86_64）
    2. echo $LANG 查看机器语言及编码（en_US.UTF-8）
    3. echo $BASH 查看当前Bash类型（/bin/bash,/bin/sh）
    4. echo $BASH_VERSION 查看bash版本（3.2.25(1)-release）
    5. echo $$ 查看当前bash的进程ID
    6. echo $MACHTYPE 查看机器类型machine type（x86_64-redhat-linux-gnu）
    7. echo $HOSTNAME 查看主机名
    8. echo $OSTYPE 查看操作系统类型（linux-gnu）
    9. echo $PATH 查看环境变量
    10. echo $LOGNAME 查看当前登录用户名
    11. echo $TERM 查看term类型（xterm）
    12. echo $RANDOM 产生随机整数
    13. 还有很多$PWD,$HISTFILE,$HISTCMD,$MAIL等，可以用 echo $ +tab tab 来查看所有的常量

### Shell脚本语言中test命令用法

先看一个命令：意思是测试当前目录下是否存在study文件（文件夹），若存在则输出exist!，否则输出not exist!

    # test -e study && echo "exist!" || echo "not exist!"

    以下是test命令常用的测试标志：
    1. 某文件名的类型检测（存在与否及文件类型）（test -e filename）
    -e :该“文件名”是否存在。 (exist)
    -d :该文件名是否为目录。 (directory)
    -f :该文件名是否为普通文件。 (file)
    b,c,S,p,L分别指的是块设备、字符设备、套接字文件、管道文件及链接文件。(block,character,socket,pipe,link)

    2. 文件权限的检测（test -r filename）
    -r :该文件是否具有可读属性 (read)
    -w :该文件是否具有可写属性 (write)
    -x :该文件是否具有可执行属性 (execute)
    -s :该文件是否为非空白文件 (space，即该文件内容均为空格组成但是至少要有一个空格)

    3. 比较两个文件（test file_a nt file_b）
    -nt :文件file_a是否比file_b新 (newer than)
    -ot :文件file_a是否比file_b旧 (older than)
    -ef :判断两个文件是否为同一文件，可用于判断硬连接。（主要判断两个文件是否均指向同一个inode）

    4. 两个整数之间的判断（test n1 -eq n2）
    -eq :两个数相等（equal）
    -ne :两个数不相等（not equal）
    -gt :前者大于后者（greater than）
    -lt :前者小于后者（less than）
    -ge :前者大于等后者 (greater or equal)
    -le :前者小于等于后者 (lower or equal)

    5. 判断字符串
    test -z str :判断字符串是否为空，若为空则回传true (zero)
    test -n str :判断字符串是否为非空，左路为非空则回传true（-n亦可省略）
    test str_a = str_b及test str_a != str_b:判断两字条串是否相等及不相等。


    6. 多重判断条件（test -r file -a -w file）
    -a :and，当两个条件都满足时才回传true，即file具有读和写权限
    -o : or，当两个条件满足其一时即回传true
    -! :条件求反，test -! -x file，即当file不具有执行权限时才回传true

### Shell中常见字串含义

    $$ 当前bash的进程号
    $!  获取上条命令执行的进程pid
    $# 获取参数个数
    $@ 获取参数列表 （$* 也是获取参数列表）
    $? 获取程序返回值（成功为0，错误为其他）
    ${#array[@]} 获取数组长度（元素个数），array为数组名
    ${array[*]}  获取数组元素列表
    ${#str}  获取字符串长度
    ${name:?error message} 检查一个变量是否存在

## Bash快捷键

生活在 Bash shell 中，熟记以下快捷键，将极大的提高你的命令行操作效率。

### 编辑命令

    Ctrl + a ：移到命令行首
    Ctrl + e ：移到命令行尾
    Ctrl + f ：按字符前移（右向）
    Ctrl + b ：按字符后移（左向）
    Alt + f ：按单词前移（右向）
    Alt + b ：按单词后移（左向）
    Ctrl + xx：在命令行首和光标之间移动
    Ctrl + u ：从光标处删除至命令行首
    Ctrl + k ：从光标处删除至命令行尾
    Ctrl + w ：从光标处删除至字首
    Alt + d ：从光标处删除至字尾
    Ctrl + d ：删除光标处的字符
    Ctrl + h ：删除光标前的字符
    Ctrl + y ：粘贴至光标后
    Alt + c ：从光标处更改为首字母大写的单词
    Alt + u ：从光标处更改为全部大写的单词
    Alt + l ：从光标处更改为全部小写的单词
    Ctrl + t ：交换光标处和之前的字符
    Alt + t ：交换光标处和之前的单词
    Alt + Backspace：与 Ctrl + w 相同类似，分隔符有些差别

### 重新执行命令

    Ctrl + r：逆向搜索命令历史
    Ctrl + g：从历史搜索模式退出
    Ctrl + p：历史中的上一条命令
    Ctrl + n：历史中的下一条命令
    Alt + .：使用上一条命令的最后一个参数

### 控制命令

    Ctrl + l：清屏
    Ctrl + o：执行当前命令，并选择上一条命令
    Ctrl + s：阻止屏幕输出
    Ctrl + q：允许屏幕输出
    Ctrl + c：终止命令
    Ctrl + z：挂起命令

刚刚接触CentOS时，这个`Ctrl + s`可把哥害惨了，不小心按了这两个键让屏幕没反应，关键是哥哥我还不知道自己按了这两个键。

### Bang (!) 命令

    !!：执行上一条命令
    !blah：执行最近的以 blah 开头的命令，如 !ls
    !blah:p：仅打印输出，而不执行
    !$：上一条命令的最后一个参数，与 Alt + . 相同
    !$:p：打印输出 !$ 的内容
    !*：上一条命令的所有参数
    !*:p：打印输出 !* 的内容
    ^blah：删除上一条命令中的 blah
    ^blah^foo：将上一条命令中的 blah 替换为 foo
    ^blah^foo^：将上一条命令中所有的 blah 都替换为 foo

## 字符串操作

* ${parameter:-word}

    If parameter is unset or null, the expansion of word is substituted. Otherwise, the value of parameter is substituted.

* ${parameter:=word}

    If parameter is unset or null, the expansion of word is assigned to parameter. The value of parameter is then substituted. Positional parameters and special parameters may not be assigned to in this way.

* ${parameter:?word}

    If parameter is null or unset, the expansion of word (or a message to that effect if word is not present) is written to the standard error and the shell, if it is not interactive, exits. Otherwise, the value of parameter is substituted.

* ${parameter:+word}

    If parameter is null or unset, nothing is substituted, otherwise the expansion of word is substituted.

* ${parameter:offset} ${parameter:offset:length}

    This is referred to as Substring Expansion. It expands to up to length characters of the value of parameter starting at the character specified by offset. If parameter is ‘@’, an indexed array subscripted by ‘@’ or ‘*’, or an associative array name, the results differ as described below. If length is omitted, it expands to the substring of the value of parameter starting at the character specified by offset and extending to the end of the value. length and offset are arithmetic expressions.

<http://tldp.org/LDP/abs/html/refcards.html#AEN22728>

<https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html>

## 创建文件（Here Documents）

```
key=value

# codeblock 1
cat <<EOF > /tmp/filename
This is the value of key: $key
EOF

# codeblock 2
cat <<'EOF' > /tmp/filename
Quotes prevent parameter expansion: $key
EOF

# codeblock 3
cat <<-EOF > /tmp/filename
Hyphen removes leading tabs
<tab>$key
EOF

# codeblock 4
tee /tmp/filename <<EOF
This is the value of key: $key
EOF

# codeblock 5
cat <<EOF
This is the value of key: $key
EOF
```

其实`EOF`也可以改成任意字符串。

1.<http://tldp.org/LDP/abs/html/here-docs.html>

2.<http://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash>

## References

学习Shell有一本必读的书《ABS Guide》

<https://linuxtoy.org/archives/bash-shortcuts.html>

<https://www.gnu.org/software/bash/manual/bashref.html>
