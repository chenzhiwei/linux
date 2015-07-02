# Yarn

Yarn 可以说是新一代的 Hadoop MapReduce，用来做资源管理、调度和监控。

## Yarn 几个概念

### Resource Manager

全局资源管理器。有两个主要的组件：Scheduler 和 ApplicationsManager。

Scheduler 就只是单纯的 Scheduler 并支持插件，只用来分配资源，不做监控和追踪工作。

ApplicationsManager 用来接受作业提交请求并执行 Application 特定的 ApplicationMaster，并且还提供当 ApplicationMaster 失败时重启 ApplicationMaster 的服务。

### Application Master

每个 Application 都有一个 Application Master，这里的 Application 可以是`single job`或`DAG of jobs`。用来从 Scheduler 选择合适的资源容器并追踪他们的状态和进度。

### Note Manager

去执行和监控任务（task）的。监控资源（CPU、Memory、Disk、Network）的使用情况并汇报给 ResourceManager/Scheduler。


## 图

![Yarn](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/yarn_architecture.gif)
