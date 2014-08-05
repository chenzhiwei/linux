# Heat

Heat用来管理OpenStack的各种资源。你可以在heat template里面添加各种资源，然后由heat统一来创建、更新或删除。

Heat可以用来创建OpenStack网络、镜像、虚拟机、用户等等东西，还可以创建一个搭载MySQL等service的虚拟机。

## Heat的组件

[heat architecture](http://docs.openstack.org/developer/heat/architecture.html)

### heat

heat客户端，是个命令行工具，和heat-api进行各种交互，终端用户也可以直接操作heat-api。

### heat-api

heat-api提供了一个OpenStack原生API通过RPC将请求传递给heat-engine。

### heat-api-cfn

与heat-api类似，只不过这个API是用来兼容AWS CloudFormation API的。

### heat-api-cloudwatch

与heat-api类似，这个API是用来兼容CloudWatch的，目前哥不知道CloudWatch不个什么东东，落后了。

### heat-engine

用来对template中的资源进行管理，并且将结果返回给API调用者。

### heat-manage

一个命令行工具，用来对heat数据库进行相关操作。

### heat-db-setup

一个命令行工具，用来配置heat本地数据库的。

### heat-keystone-setup

一个命令行工具，用来配置keystone让其和heat配合使用的。

## Heat Template

[heat template guide](http://docs.openstack.org/developer/heat/template_guide/index.html)

在template里添加各种资源，然后heat会根据模板里的这些资源来调用OpenStack相关组件的API来进行操作。

## Environments

Environment用来重写一个template运行时的属性或动作，比如template里设置一个用户的密码是`123456`，那么你可以在environment里override这个密码。

## Heat resource life cycle

[heat资源生命周期](http://docs.openstack.org/developer/heat/pluginguide.html)

* create
* update
* suspend
* resume
* delete

## Heat调用过程

```
CLI ---> RESET-API ---> AMQP ---> ENGINE
```

Heat的各个组件都可以有多个。

## Heat源码索引

<http://docs.openstack.org/developer/heat/sourcecode/autoindex.html>

## Heat的用法

<http://openstack.redhat.com/Deploy_an_application_with_Heat>
