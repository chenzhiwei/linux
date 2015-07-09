# Hadoop Yarn

Hadoop Yarn single node cluster pseudo-distributed setup.


## Install Required packages

```
# yum install ssh rsync java-1.7.0-openjdk-headless
```


## Download Hadoop Yarn package

Download the pre-build package: <http://www.apache.org/dyn/closer.cgi/hadoop/common/>

```
# cd /usr/local
# wget http://www.us.apache.org/dist/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
# tar xf hadoop-2.6.0.tar.gz
```

In this case, the Hadoop home directory is `/usr/local/hadoop-2.6.0`.


## Set environment

Change to Hadoop home directory:

* Add below environment to `etc/hadoop/hadoop-env.sh`

```
# set to the root of your Java installation
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.75-2.5.4.2.el7_0.x86_64/jre

# set to the home directory of Hadoop
export HADOOP_PREFIX=/usr/local/hadoop-2.6.0
```

* Run below command

```
# bin/hadoop
```

This will display the usage of `bin/hadoop` command.


## Configuration file

Change to Hadoop home directory:

* etc/hadoop/core-site.xml

```
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
```

* etc/hadoop/hdfs-site.xml

```
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>
```

* etc/hadoop/mapred-site.xml

```
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

* etc/hadoop/yarn-site.xml

```
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>
```


## Setup passphraseless ssh

```
# ssh localhost
# ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
# cat ~/.ssh/id_rsa.put >> ~/.ssh/authorized_keys
```


## Execution and start

### Format the filesystem

```
# bin/hdfs namenode -format
```

### Start NameNode and DataNode Daemon

```
# sbin/start-dfs.sh
```

The logs will be in `logs` directory under Hadoop home.

### Make the HDFS directories required to execute MapReduce jobs

```
# bin/hdfs dfs -mkdir /user
# bin/hdfs dfs -mkdir /user/<username>
```

I changed the `<username>` to `root`, and des not really know what this mean.

### Start ResourceManage and NodeManager daemon

```
# sbin/start-yarn.sh
```


## Submit a job

Change to Hadoop home directory.

### Check the available example commands

```
# bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar
```

### Submit a wordcount job

* Create a directory with a file in it

```
# mkdir local-input
# vim local-input/words.txt
```

The conent of `local-input/words.txt` can be:

```
Do you know how to use Hadoop
I do not know how to use Hadoop
```

* Put this directory to Hadoop filesystem

```
# bin/hadoop fs -put local-input remote-input
# bin/hadoop fs -ls
```

* Run the wordcount job

```
# bin/yarn jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount remote-input remote-output
# bin/hadoop fs -ls
# bin/hadoop fs -ls remote-output
```

* View the result remotely

```
# bin/hadoop fs -cat remote-output/*
```

The output will be:

```
Do      1
Hadoop  2
I       1
do      1
how     2
know    2
not     1
to      2
use     2
you     1
```

* Get the output to local and view

```
# bin/hadoop fs -get remote-output local-output
# ls local-output
# cat local-output/*
```


## View the job in GUI

Open your browser, visit <http://localhost:8088>


## Stop Hadoop Yarn

```
# sbin/stop-dfs.sh
# sbin/stop-yarn.sh
```


## References

<http://hadoop.apache.org/docs/r2.6.0/hadoop-project-dist/hadoop-common/SingleCluster.html>
