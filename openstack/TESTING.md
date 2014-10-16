# OpenStack Dev

## 搭建OpenStack Unit Test环境(nova)

### 安装虚拟环境所需软件包

* Ubuntu

```
$ sudo apt-get install python-dev libssl-dev python-pip git-core libxml2-dev libxslt-dev pkg-config libffi-dev libpq-dev libmysqlclient-dev
```

* CentOS/RHEL/Fedora

```
# yum install libffi-devel postgresql-devel gcc mysql python-pep8 openssl-devel libxml2-devel  libxslt-devel mysql-devel
```

### 创建虚拟环境（venv）

```
$ git clone https://github.com/openstack/nova
$ cd nova
$ ./run_tests.sh --update
$ ./run_tests.sh nova.tests.virt.libvirt.test_libvirt
$ source .venv/bin/activate
$ pip install flake8
$ pip install hacking
$ flake8 nova/scheduler/utils.py
$ flake8 --config=tox.ini nova/scheduler/utils.py
$ pip install nose
$ nosetests nova/tests/
$ nosetests nova/tests/test_file.py
$ nosetests nova.tests.virt.libvirt.test_libvirt
$ nosetests -s -v nova/tests/virt/libvirt/test_libvirt.py:LibvirtDriverTestCase.test_finish_revert_migration_power_on
```

* flake8

`flake8`是用来做代码风格检查的，可以简单的认为是`pep8`、`pyflake`等的集合。

* hacking

`hacking`是一系列`flake8`的插件，主要用来增强`OpenStack`项目代码检查。

* nosetests

`nosetests`是一个执行Python Unit Test的工具。

## Reference

<http://docs.openstack.org/developer/nova/devref/development.environment.html>

<https://github.com/openstack-dev/hacking/>
