#!/bin/bash
. ./define.sh

function install_packages() {
    apt-get -y install mysql-server memcached rabbitmq-server \
        apache2 libapache2-mod-wsgi python-mysqldb
}

function configure_mysql() {
    sed -i 's/127.0.0.1/0.0.0.0/g' $MY_CONF
    service mysql restart
}

function install_keystone_packages() {
    ks_packages=("keystone" "python-keystone" "python-keystoneclient")
    apt-get -y install ${ks_packages[@]}
}

function create_tenant() {
    name=$1
    desc="$2"
    keystone --token=$TOKEN --endpoint=$ENDPOINT tenant-create \
        --name=$name --description="$desc" --enabled=true
}

function get_tenant_id() {
    name=$1
    mysql -uroot -p$MY_PASS -sN -e \
        "select id from keystone.tenant where name = '$name'"
}

function create_user() {
    tenant=$1
    name=$2
    pass=$3
    email=$4
    keystone --token=$TOKEN --endpoint=$ENDPOINT user-create \
        --tenant-id=$tenant --name=$name --pass=$pass \
        --email=$email --enabled=true
}

function get_user_id() {
    name=$1
    mysql -uroot -p$MY_PASS -sN -e \
        "select id from keystone.user where name = '$name'"
}

function create_role() {
    name=$1
    keystone --token=$TOKEN --endpoint=$ENDPOINT role-create \
        --name=$name
}

function get_role_id() {
    name=$1
    mysql -uroot -p$MY_PASS -sN -e \
        "select id from keystone.role where name = '$name'"
}

function create_service() {
    name=$1
    type=$2
    desc="$3"
    keystone --token=$TOKEN --endpoint=$ENDPOINT service-create \
        --name=$name --type=$type --description="$desc"
}

function get_service_id() {
    name=$1
    mysql -uroot -p$MY_PASS -sN -e \
        "select id from keystone.service where extra like '%\"name\": \"$name\"%'"
}

function create_user_role() {
    tenant=$1
    user=$2
    role=$3
    keystone --token=$TOKEN --endpoint=$ENDPOINT user-role-add \
        --user_id=$user --tenant_id=$tenant --role_id=$role
}

function create_endpoint() {
    region=$1
    service=$2
    publicurl="$3"
    internalurl="$4"
    adminurl="$5"
    keystone --token=$TOKEN --endpoint=$ENDPOINT endpoint-create \
        --region=$region --service-id=$service --publicurl="$publicurl" \
        --internalurl="$internalurl" --adminurl="$adminurl"
}

function create_keystone_db() {
    sql_create="CREATE DATABASE keystone"
    sql_grant="GRANT ALL ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$MY_KS_PASS'"
    mysql -u root -p$MY_PASS -e "$sql_create"
    mysql -u root -p$MY_PASS -e "$sql_grant"
}

function configure_keystone() {
    sed -i 's#connection = sqlite.*$#connection = mysql://keystone:'$MY_KS_PASS'@'$HOST'/keystone#g' $KS_CONF
    sed -i 's/# admin_token = ADMIN/admin_token = '$TOKEN'/g' $KS_CONF

    service keystone restart

    # create tables in keystone db
    keystone-manage db_sync

    # create demo tenant
    create_tenant $TENANT_NAME "$TENANT_DESC"
    # get demo tenant id
    TENANT_ID=$(get_tenant_id $TENANT_NAME)

    # create user
    create_user $TENANT_ID $USERNAME $PASSWORD $EMAIL
    # get user id
    USER_ID=$(get_user_id $USERNAME)

    # create role
    create_role $ROLE
    # get role id
    ROLE_ID=$(get_role_id $ROLE)

    # grant the $ADMIN_ROLE role to the $OS_USERNAME user
    # in the $OS_TENANT_NAME tenant
    create_user_role $TENANT_ID $USER_ID $ROLE_ID

    # create identify(keystone) service
    create_service $KS_NAME $KS_TYPE "$KS_DESC"
    # get keystone service id
    KS_ID=$(get_service_id $KS_NAME)
    # create keystone endpoint
    create_endpoint $REGION $KS_ID $KS_PUBURL $KS_INTURL $KS_ADMURL

    # create Compute(nova) service
    create_service $NV_NAME $NV_TYPE "$NV_DESC"
    # get service id
    NV_ID=$(get_service_id $NV_NAME)
    # create endpoint
    create_endpoint $REGION $NV_ID $NV_PUBURL $NV_INTURL $NV_ADMURL

    # create Image(glance) service
    create_service $GL_NAME $GL_TYPE "$GL_DESC"
    # get service id
    GL_ID=$(get_service_id $GL_NAME)
    # create endpoint
    create_endpoint $REGION $GL_ID $GL_PUBURL $GL_INTURL $GL_ADMURL

    # create Volume(cinder) service
    create_service $CD_NAME $CD_TYPE "$CD_DESC"
    # get service id
    CD_ID=$(get_service_id $CD_NAME)
    # create endpoint
    create_endpoint $REGION $CD_ID $CD_PUBURL $CD_INTURL $CD_ADMURL

    # create Network(quantum) service
    create_service $QT_NAME $QT_TYPE "$QT_DESC"
    # get service id
    QT_ID=$(get_service_id $QT_NAME)
    # create endpoint
    create_endpoint $REGION $QT_ID $QT_PUBURL $QT_INTURL $QT_ADMURL

    # still have ec2 and swift to create
    # http://docs.openstack.org/trunk/openstack-compute/install/content/keystone-service-endpoint-create.html
    # all these users, rols and telants in the mysql:keystone db
}
