# MySQL速查

## MySQL启动与更改密码

安装好MySQL之后，先启动MySQL服务（service mysqld start 或 /etc/init.d/mysqld start）

为MySQL的root用户设置密码（mysqladmin -uroot password 123456）

修改密码命令（mysqladmin -uroot -p123456 password newpasswd）

change password in safe:

    # /etc/init.d/mysqld stop
    # mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
    # mysql -u root mysql
    mysql> UPDATE user SET Password=PASSWORD('newpassword') where USER='root';
    mysql> FLUSH PRIVILEGES;
    mysql> quit

## 备份及导入数据库

```
mysqldump -u db_user -p -h 127.0.0.1 db_name > db_name.sql
mysql -u db_user -p -D db_name < db_name.sql
```


## MySQL常用语句

    show  global variables like '%engine%'; 查看MySQL默认引擎
    show databases;
    show grants for 'username'@'%';
    drop database db_name;
    show tables;
    drop table table_name;
    select * from table_name;
    select count(*) as count from app; //修改第一列的名字
    select * from table_name where id=1;
    select type from node2module join node on node2module.nid = node.id where node.ip='10.1.1.1' and node2module.mname = 'web';
    create table user(id int not null auto_increment, name varchar(18), passwd varchar(25), role enum('admin', 'user') not null default 'user', primary key (id) );
    alter table user rename to users;
    alter table user change name username varchar(18), passwd password(25);
    alter table user change name username varchar(18) not null after role; 改变字段顺序
    alter table user add birthday date;
    alter table user modify passwd varchar(50);
    alter table user drop COLUMN passwd;
    insert into user values(1,"zhiwei","123456");
    insert into user(name, passwd) values('zhiwei', '123456');
    update user set name='zhiwei5',password='123456' where id=1;
    grant ALL ON db_name.* to db_user@'10.%' identified by "123456" with grant option;
    revoke ALL ON db_name.* to db_user@'10.%' identified by "123456";
    alter table set engine='InnoDB'
    ALTER  TABLE  `table_name`  ADD  PRIMARY  KEY (  `column`  )
    ALTER  TABLE  `table_name`  ADD  UNIQUE (`column` )
    ALTER  TABLE  `table_name`  ADD  INDEX index_name (  `column`  )
    ALTER  TABLE  `table_name`  ADD  FULLTEXT ( `column` )
    ALTER  TABLE  `table_name`  ADD  INDEX index_name (  `column1`,  `column2`,  `column3`  )
    show index from table_name

    UPDATE ultra_event u JOIN event e ON (u.id = e.id) SET u.start_time = unix_timestamp(e.apply_end)

    复制一个表： CREATE TABLE ultra_event LIKE event; INSERT ultra_event SELECT * FROM event;
    将A表数据插入到B表： insert B(title, content) select title, content from A where xx = xx.

    有时数据库表名和字段名可能会有mysql保留的关键字，因此需要用反引呈来转义，如下：
    CREATE TABLE `users` (
            `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
            `user_name` varchar(50) NOT NULL DEFAULT '',
            `qq_openid` varchar(32) NOT NULL,
            `user_avatar` varchar(100) NOT NULL DEFAULT '',
            `user_email` varchar(100) NOT NULL DEFAULT '',
            `user_registered` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
            `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `user_status` int(11) NOT NULL DEFAULT '0',
            PRIMARY KEY (`ID`),
            KEY `user_login_key` (`qq_openid`)
            ) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
    以上这条语句中KEY意思是对qq_openid做索引，AUTO_INCREMENT=5代表id从5开始自增。

    MySQL 批量替换字符串：将字段content里的所有source字符串替换成dest
    UPDATE table_name SET content = REPLACE(content, 'source', 'dest');
