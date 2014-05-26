##SNMP是什么
SNMP是基于TCP/IP协议族的网络管理标准，它的前身是简单网关监控协议(SGMP)，用来对通信线路进行管理。
##Net-SNMP
Net-SNMP是一个免费的、开放源码的SNMP实现.[官网](http://www.net-snmp.org/)
##下载
    wget http://sourceforge.net/projects/net-snmp/files/net-snmp/5.3.3/net-snmp-5.3.3.tar.gz
##安装配置
安装之前确认libtool，openssl，zlib软件已经安装

    gunzip net-snmp-5.3.3.tar.gz
    tar -xvf net-snmp-5.3.3.tar
    cd net-snmp-5.3.3
    ./configure --prefix=/usr/local/net-snmp --enable-mfd-rewrites --with-default-snmp-version="2" --with-sys-location="China" --with-sys-contact="Email:xxxx@xxxx.com" --with-logfile="/usr/local/net-snmp/log/snmpd.log"  --with-persistent-directory="/var/net-snmp"
注释：

* prefix：net-snmp将要安装的路径。
* enable-mfd-rewrites：允许用新的MFD重写可用的mid模块
* with-default-snmp-version：默认的SNMP版本
* with-sys-contact：可以配置该设备的联系人
* with-sys-location：该设备的位置
* with-logfile：日志文件路径
* with-persistent-directory：不变数据存储目录
 
##编译安装

    make && make install

##配置snmpd.conf

配置snmpd.conf文件
首先我们把源文件中的EXAMPLE.conf文件复制到/usr/local/net-snmp/share/snmp目录下并命名为snmp.conf

    cp EXAMPLE.conf /usr/local/net-snmp/share/snmp/snmpd.conf
    
编辑snmp.conf文件

```
#       sec.name  source          community 这个配置项
#(sec.name：安全体名称 
#source：定义请求的来源，在IP协议中，这个数据是IP地址。在net-snmp中用来对来源IP加以控制，但这个特性不是SNMP规定的，是net-snmp扩展的 .
#community：共同体名称 )
#原来的
com2sec local     localhost       COMMUNITY
com2sec mynetwork NETWORK/24      COMMUNITY

#修改后的
com2sec local     localhost       public
com2sec mynetwork 192.168.8.30   public
com2sec mynetwork 192.168.11.29   public
```
##设置net-snmp自启动     
在/etc/rc.local文件末尾加入以下代码    -c代表以以下配置文件启动

    /usr/local/net-snmp/sbin/snmpd -c /usr/local/net-snmp/share/snmp/snmpd.conf &  
##设置环境变量     
在/etc/profile末尾加入以下代码    

    PATH=/usr/local/net-snmp/bin:/usr/local/net-snmp/sbin:$PATH
    
使环境变量设置生效  

    source /etc/profile    
##启动snmp

    /usr/local/net-snmp/sbin/snmpd -d     
    #查看服务是否启动     
    Netstat -na | grep 161 
    #snmp使用的端口161
    
##测试

    snmpwalk -v 2c -c public localhost if
    #若出现以下信息，则正确启动snmpd服务
    IF-MIB::ifIndex.1 = INTEGER: 1
    IF-MIB::ifIndex.3 = INTEGER: 3
    IF-MIB::ifIndex.4 = INTEGER: 4
    IF-MIB::ifIndex.5 = INTEGER: 5
    IF-MIB::ifIndex.6 = INTEGER: 6
    IF-MIB::ifDescr.1 = STRING: lo
    IF-MIB::ifDescr.3 = STRING: eth0
    IF-MIB::ifDescr.4 = STRING: eth1
    IF-MIB::ifDescr.5 = STRING: sit0
    IF-MIB::ifDescr.6 = STRING: usb0
