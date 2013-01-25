#!/bin/bash

function install_glance_packages() {
    glance_packages=("glance" "glance-api" "glance-common" "glance-registry" \ 
        "python-glance" "python-glanceclient")

    apt-get -y install ${glance_packages[@]}
}

function create_glance_db() {
    sql_create="CREATE DATABASE glance"
    sql_grant="GRANT ALL ON glance.* TO 'glance'@'%' IDENTIFIED BY '$MY_GL_PASS'"
    mysql -u root -p$MY_PASS -e "$sql_create"
    mysql -u root -p$MY_PASS -e "$sql_grant"
}

function configure_glance() {
    sed -i 's#connection = sqlite.*$#connection = mysql://glance:'$MY_GL_PASS'@'$HOST'/glance#g' $GL_API_CONF
    sed -i 's/^#flavor=.*/flavor = keystone/g' $GL_API_CONF
    sed -i 's#connection = sqlite.*$#connection = mysql://glance:'$MY_GL_PASS'@'$HOST'/glance#g' $GL_REGISTRY_CONF
    sed -i 's/^#flavor=.*/flavor = keystone/g' $GL_REGISTRY_CONF
    glance-manage db_sync
}

function upload_glance_image() {
    glance image-create name="linux-image-kernel" disk_format=aki \
        container_format=aki < /data0/images/kernel
    glance image-create name="linux-image-ramdisk" disk_format=ari \
        container_format=ari < /data0/images/ramdisk
    glance image-create name="linux-image-img" disk_format=ami \
        container_format=ami --property kernel_id=xxx --property \
        ramdisk_id=xxx < /data0/images/ubuntu.img
}
