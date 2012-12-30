#!/bin/bash

hosts=(mail.google.com www.google.com www.google.com.hk
    chatenabled.mail.google.com filetransferenabled.mail.google.com)
for host in ${hosts[@]}
do
    ips=$(dig +short @8.8.8.8 $host A | grep -v "^[^1-9]")
    for ip in $ips
    do
        if nc -w 3 -z $ip 443; then
            sed -i '/[ \t]\+'$host'$/d' /etc/hosts
            echo -e "$ip\t$host" >> /etc/hosts
        fi
    done
done
