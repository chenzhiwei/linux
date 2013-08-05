# DB2

## Usage

```
# su - db2inst1
```

### Create database

```
# su - db2inst1
$ db2 CREATE DATABASE db_name
```

### Drop database

```
# su - db2inst1
$ db2 DROP DATABASE db_name
```

### List all databases

```
# su - db2inst1
$ db2 LIST DATABASE DIRECTORY
```

### List all schemas

```
# su - db2inst1
$ db2 'select SCHEMANAME from SYSCAT.SCHEMATA'
```

### Show database tables

```
# su - db2inst1
$ db2 CONNECT TO db_name user db_user using db_pass
$ db2 LIST TABLES
$ db2 LIST TABLES FOR ALL
$ db2 LIST TABLES FOR USER xxx
$ db2 LIST TABLES FOR SCHEMA xxx
```

### A full db2 commands

Create a database `keystone`, a user `keystone` and password `passw0rd`

```
# useradd --system -d /home/keystone -s /bin/bash keystone
# echo passw0rd | passwd keystone --stdin
# su - db2inst1
$ db2 CREATE DATABASE keystone AUTOMATIC STORAGE YES USING CODESET UTF-8 TERRITORY CN COLLATE USING SYSTEM PAGESIZE 8192
$ connect to keystone
$ grant dbadm on database to user keystone
$ CREATE SCHEMA keystone AUTHORIZATION keystone
```

Use the new database `keystone`

```
# su - db2inst1
$ db2 connect to keystone user keystone using passw0rd
$ db2 list tables
```

## Make DB2 Primary node

```
update db cfg for dbname using HADR_REMOTE_INST db2inst1 HADR_SYNCMODE NEARSYNC HADR_TIMEOUT 120 HADR_PEER_WINDOW 30 LOGARCHMETH1 LOGRETAIN LOGINDEXBUILD ON SELF_TUNING_MEM OFF AUTO_MAINT OFF AUTORESTART OFF

update db cfg for dbname using HADR_REMOTE_HOST 172.16.1.26

update db cfg for dbname using HADR_LOCAL_HOST 172.16.1.25

update db cfg for dbname using HADR_REMOTE_SVC 10000

update db cfg for dbname using HADR_LOCAL_SVC 10000

backup db dbname to /home/db2inst1/backup/dbname

start hadr on db dbname as primary by force
```

```
restore db dbname from /home/db2inst1/backup/dbname replace history file

update db cfg for dbname using HADR_REMOTE_INST db2inst1 HADR_SYNCMODE NEARSYNC HADR_TIMEOUT 120 HADR_PEER_WINDOW 30 LOGARCHMETH1 LOGRETAIN LOGINDEXBUILD ON SELF_TUNING_MEM OFF AUTO_MAINT OFF AUTORESTART OFF

update db cfg for dbname using HADR_REMOTE_HOST 172.16.1.25

update db cfg for dbname using HADR_LOCAL_HOST 172.16.1.26

update db cfg for dbname using HADR_REMOTE_SVC 10000

update db cfg for dbname using HADR_LOCAL_SVC 10000

start hadr on db dbname as standby
```

```
su - db2inst1 -c 'db2 takeover hadr on db dbname by force'
su - db2inst1 -c 'db2 start hadr on db dbname as standby'
```

## Read items from standby node

Set `DB2_HADR_ROS` to on.

```
# su - db2inst1
$ db2
db2 => !db2set DB2_HADR_ROS=ON
db2 => !db2set
db2 => deactivate db db_name
db2 => !db2stop
db2 => !db2start
db2 => activate db db_name
db2 => connect to db_name
db2 => select * from db_table with UR
```

## Resources

1. http://www.ibm.com/developerworks/data/library/techarticle/dm-1205hadrstandby/
