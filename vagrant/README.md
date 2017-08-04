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

## Set the box size

```
cd ~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-xenial64/20170803.0.0/virtualbox
VBoxManage clonehd ubuntu-xenial-16.04-cloudimg.vmdk tmp.vdi --format vdi
VBoxManage modifyhd tmp.vdi --resize 102400
clonehd tmp.vdi tmp.vmdk --format vmdk
mv tmp.vmdk ubuntu-xenial-16.04-cloudimg.vmdk
rm -f tmp.vdi
```

## More

I don't like GUI, so there is no VirtualBox here.

<https://github.com/vagrant-libvirt/vagrant-libvirt>
