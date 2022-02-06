# Vagrant with libvirt

## Installing

Deb/RPM: https://releases.hashicorp.com/vagrant/

* Ubuntu/Debian

```
sudo dpkg -i vagrant.deb
sudo apt install libvirt-daemon-system qemu-utils qemu-system-x86 libvirt-dev --no-install-recommends
vagrant plugin install vagrant-libvirt
```

* RHEL/CentOS/Fedora

```
$ sudo rpm -i vagrant.rpm
$ sudo yum install libxslt-devel libxml2-devel libvirt-devel libguestfs-tools-c
$ export PATH=/opt/vagrant/embedded/bin:$PATH
$ vagrant plugin install vagrant-libvirt
```

## Vagrant disksize plugin

```
vagrant plugin install vagrant-disksize
```

Set disksize like following:

```
vagrant.configure('2') do |config|
    config.vm.box = 'ubuntu/bionic64'
    config.disksize.size = '50GB'
end
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
