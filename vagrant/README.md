# Vagrant with libvirt

## Installing

* Ubuntu/Debian

```
$ sudo dpkg -i vagrant.deb
$ sudo apt-get install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev
$ export PATH=/opt/vagrant/embedded/bin:$PATH
$ vagrant plugin install vagrant-libvirt
```

* RHEL/CentOS/Fedora

```
$ sudo rpm -i vagrant.rpm
$ sudo yum install libxslt-devel libxml2-devel libvirt-devel libguestfs-tools-c
$ export PATH=/opt/vagrant/embedded/bin:$PATH
$ vagrant plugin install vagrant-libvirt
```

## Using

```
$ mkdir vagrant
$ cd vagrant
$ vagrant init centos/7
$ vagrant up --provider libvirt
$ export VAGRANT_DEFAULT_PROVIDER=libvirt
$ vagrant up
$ vagrant ssh dcos1
```

## More

I don't like GUI, so there is no VirtualBox here.

<https://github.com/vagrant-libvirt/vagrant-libvirt>
