#!/bin/bash

HOST=10.73.26.252
MY_PASS=123456
MY_KS_PASS=123456
MY_CONF=/etc/mysql/my.cnf
TOKEN=$(echo -n openstack | md5sum | awk '{print $1}')
ENDPOINT=http://$HOST:35357/v2.0

TENANT_NAME=DemoTenant
TENANT_DESC="This is a DemoTenant"
USERNAME=DemoUser
PASSWORD=123456
EMAIL=zhiweik@gmail.com
ROLE=DemoRole

KS_NAME=keystone
NS_NAME=nova
VS_NAME=volume
IS_NAME=image
