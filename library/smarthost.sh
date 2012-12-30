#!/bin/bash

smarthost="smarthosts.googlecode.com"

function get_valid_ip() {
    local ips=$(dig +short @8.8.8.8 $smarthost A | grep -v "^[^1-9]")
    for ip in $ips
    do
        if nc -w 3 -z $ip 443; then
            echo $ip
            exit 0
        fi
    done
}

function get_hosts() {
    if nc -w 3 -z $smarthost 443; then
        curl -k -sS "https://$smarthost/svn/trunk/hosts"|awk '!/^127/ && /^[1-9]/'
        exit 0
    fi
    local ip=$(get_valid_ip)
    if [ "x$ip" = "x" ]; then
        echo "connect to $smarthost failed!"
        exit 1
    fi
    curl -k -sS -H"Host: $smarthost" "https://$ip/svn/trunk/hosts"|awk '!/^127/ && /^[1-9]/'
}

function update_host() {
    local ip=$1
    local host=$2
    local old_ip=$(awk '/[ \t]+'$host'$/ && !/^#/{print $1;exit;}' /etc/hosts)
    if [ "x$ip" != "x$old_ip" ]; then
        echo "update $host"
        sed -i "/[ \t]\+$host$/d" /etc/hosts
        echo -e "$ip\t$host" >> /etc/hosts
    fi
}

hosts=$(get_hosts)

while read line
do
    ip=$(echo $line | awk '{print $1}')
    host=$(echo $line | awk '{print $2}' | grep -o "[0-9a-zA-Z\.\-]*")
    update_host $ip $host
done<<EOF
$hosts
EOF
