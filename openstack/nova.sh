#!/bin/bash

function install_nova_packages() {
    nova_packages=("nova" "nova-api")
    apt-get -y install ${nova_packages[@]}
}

function create_nova_db() {
    sql_create="CREATE DATABASE nova"
    sql_grant="GRANT ALL ON nova.* TO 'nova'@'%' IDENTIFIED BY '$MY_NV_PASS'"
    mysql -u root -p$MY_PASS -e "$sql_create"
    mysql -u root -p$MY_PASS -e "$sql_grant"
}

function configure_nova() {
}

# http://wiki.openstack.org/LibvirtXMLCPUModel
