#!/bin/bash
#
# * Tue Jan 08 2013  Chen Zhiwei <zhiweik@gmail.com>
# - Written this vm manage script
#
# /var/images/centos-6.2.x86_64
# |--- centos-6.2.x86_64.img
# |--- instance-hostname.xml
# |--- kernel
# `--- ramdisk
#

STATUS=0
INI_FILE=/var/images/vms.ini
BASE_DIR=/var/instances
IMG_DIR=/var/images

IP=$(ip a | awk -F"[ /]" '/inet /{if($6 ~ /10\.(67\.15|73\.26|75\.7)\./)\
    {print $6;exit;}}')

function ini_parser() {
    local vms=$(sed -e 's/[ \t]\+//g' -e '/^;/d' $INI_FILE)
    if [ -z "$vms" ]; then
    	echo -e "ERROR\tnull vm config file"
    	STATUS=1
    	return $STATUS
    fi
    echo "$vms"
}

function gen_mac_addr(){
    local mac="fa:16:$(dd if=/dev/urandom count=1 2>/dev/null \
        | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4/')"
    echo $mac
}

function check_env() {
    local dir=$IMG_DIR/$1
    if [ ! -e $dir ]; then
    	echo -e "ERROR\tbase image($1) not exist"
    	STATUS=1
    	return $STATUS
    fi
}

function prepare() {
    local dir=$IMG_DIR/$1
    local hostname=$2
    local disk=$3
    local instance_xml=$BASE_DIR/instance-$hostname/instance-$hostname.xml
    cp -rf $dir $BASE_DIR/instance-$hostname
    mv $BASE_DIR/instance-$hostname/instance-hostname.xml $instance_xml 
    qemu-img create $BASE_DIR/instance-$hostname/disk.local ${disk}G
}

function edit_config() {
    local ver=$1
    local hostname=$2
    local ipaddr=$3
    local mem=$4
    local cpu=$5
    local gateway=$(echo $ipaddr | sed 's/\(^10\.[0-9]*\.[0-9]*\.\)[0-9]*$/\11/g')
    local instance_xml=$BASE_DIR/instance-$hostname/instance-$hostname.xml
    local uuid=$(uuidgen)
    local mac_addr0=$(gen_mac_addr)
    local mac_addr1=$(gen_mac_addr)
    mem=$((mem * 1024))

    sed -i -e 's/hostname-uuid/'$uuid'/g' -e 's/hostname/'$hostname'/g' \
        -e 's/memsize/'$mem'/g' -e 's/cpunum/'$cpu'/g' \
        -e 's/mac_addr0/'$mac_addr0'/g' -e 's/mac_addr1/'$mac_addr1'/g' \
        -e 's/hyper_ipaddr/'$IP'/g' $instance_xml

    mkdir /mnt/$hostname
    mount -o loop $BASE_DIR/instance-$hostname/$ver.img /mnt/$hostname
    sed -i -e 's/0.0.0.0/'$ipaddr'/g' -e 's/0.0.0.1/'$gateway'/g' \
        /mnt/$hostname/etc/sysconfig/network-scripts/ifcfg-eth1
    sed -i 's/^HOSTNAME=.*/HOSTNAME='$hostname'/g' /mnt/$hostname/etc/sysconfig/network
    umount /mnt/$hostname && rm -rf /mnt/$hostname
}

function vm_create() {
    local type=$1
    local ver=$2
    local hostname=$3
    local ipaddr=$4
    local cpu=$5
    local mem=$6
    local disk=$7
    if [ $type == "m1" ]; then
        cpu=2
        mem=2048
        disk=50
    elif [ $type == "x1" ]; then
        cpu=4
        mem=4096
        disk=100
    else
    	echo -e "ERROR\tvm $hostname type error"
    	STATUS=1
    	return $STATUS
    fi
    check_env $ver $hostname || return $STATUS
    prepare $ver $hostname $disk || return $STATUS
    edit_config $ver $hostname $ipaddr $mem $cpu || return $STATUS
    # virsh define $BASE_DIR/instance-$hostname/instance-$hostname.xml
}

function check_vms_is_exist() {
    local vms=$(ini_parser)	
    for vm in $vms
    do
        type=$(echo $vm | awk -F"[=|]" '{print $1}')
        ver=$(echo $vm | awk -F"[=|]" '{print $2}')
        hostname=$(echo $vm | awk -F"[=|]" '{print $3}')
        ipaddr=$(echo $vm | awk -F"[=|]" '{print $4}')
        cpu=$(echo $vm | awk -F"[=|]" '{print $5}')
        mem=$(echo $vm | awk -F"[=|]" '{print $6}')
        disk=$(echo $vm | awk -F"[=|]" '{print $7}')
        if [ ! -d $BASE_DIR/instance-$hostname/ ]; then
            vm_create $type $ver $hostname $ipaddr $cpu $mem $disk
        fi
    done
}

function vm_status() {
    local hostname=$1
    if ps aux | grep -v " grep " | grep -q "instance-$hostname "; then
    	return 0
    else
    	return 1
    fi
}

function vm_start() {
    local hostname=$1
    local instance_xml=$BASE_DIR/instance-$hostname/instance-$hostname.xml
    if ! vm_status $hostname; then
        virsh create $instance_xml
        if [ $? -ne 0 ]; then
            echo -e "ERROR\tvm $hostname start error"
            STATUS=1
        else
            echo -e "OK\tvm $hostname start ok"
        fi
    else
    	echo -e "OK\tvm $hostname already started"
    fi
}

function vm_stop() {
    local hostname=$1
    if vm_status $hostname; then
    	virsh destroy instance-$hostname
    	if [ $? -ne 0 ]; then
    		echo -e "ERROR\tvm $hostname stop error"
    		STATUS=1
    	else
    		echo -e "OK\t vm $hostname stop ok"
    	fi
    else
    	echo -e "OK\tvm $hostname already stopped"
    fi
}

function status() {	
    local vms=$(ini_parser)
    for vm in $vms
    do
        hostname=$(echo $vm | awk -F"[=|]" '{print $3}')
        if vm_status $hostname; then
        	echo -e "OK\tvm $hostname is running..."
        else
        	echo -e "ERROR\tvm $hostname is not running..."
        	STATUS=1
        fi
    done
}

function start() {
    local vms=$(ini_parser)
    for vm in $vms
    do
        hostname=$(echo $vm | awk -F"[=|]" '{print $3}')
        vm_start $hostname
    done
}

function stop() {
    local vms=$(ini_parser)
    for vm in $vms
    do
        hostname=$(echo $vm | awk -F"[=|]" '{print $3}')
        vm_stop $hostname
    done
}

case $1 in
    start)
        check_vms_is_exist
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: /etc/init.d/vm_manage {start|stop|status}"
        exit 1
esac

exit $STATUS
