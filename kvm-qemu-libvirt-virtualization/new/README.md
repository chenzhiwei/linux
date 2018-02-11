# KVM virtualization

## Edit QCow2 image

### Use guestmount

```
guestmount -a rhel.qcow2 -i /mnt
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
chroot /mnt
```

Then do whatever you want to do, usually you want to disable cloud-init:

```
systemctl disable cloud-config.service cloud-final.service cloud-init.service cloud-init-local.service NetworkManager.service postfix.service
yum install vim git
rm -f /etc/udev/rules.d/70-persistent-*
```


### or Use guestfish

```
guestfish --rw -a rhel.qcow2
><fs> run
><fs> list-filesystems
><fs> mount /dev/vda1 /
><fs> vi /etc/shadow
><fs> ln-sf /dev/null /etc/systemd/system/cloud-init.service
```


## Resize QCow2 image

```
qemu-img info rhel.qcow2
cp rhel.qcow2 rhel.final.qcow2
qemu-img resize rhel.qcow2 +100G
virt-filesystems --long -h --all -a rhel.final.qcow2
virt-resize --expand /dev/sda1 rhel.qcow2 rhel.final.qcow2
virt-filesystems --long -h --all -a rhel.final.qcow2
```

If the filesystem of `rhel.qcow2` is xfs, then you need to boot this image as a running VM, login to this VM and run `xfs_growfs /dev/sda1` to resize it.


## Shrink(Compress) QCow2 image

```
virt-sparsify --compress --convert qcow2 --format qcow2 input.qcow2 output.qcow2
```

<hr>

## KVM(Libvirt) create a network

```
virsh net-define virbr1.xml
virsh net-start second
virsh net-autostart second
```

## KVM(Libvirt) start a vm from qcow2

```
virt-install --name=rhel --memory=1024 --vcpu=4 --graphics=vnc,listen=0.0.0.0 --disk=rhel-server-7.4-x86_64-kvm.qcow2 --import
```

Append `--print-xml` to above command to only print the xml file, later we can use the xml file to custom our VM.


## KVM(Libvirt) start a vm from xml file

```
virsh create domain.xml
virsh destroy name-xxx
virsh help
```
