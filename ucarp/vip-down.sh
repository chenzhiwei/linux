#!/bin/bash

ip=$2
iface=$1

if [[ ! "$ip" =~ "/" ]]; then
    ip=$ip/32
fi

if ip addr show $iface | grep -wq $ip; then
    ip addr del $ip dev $iface
fi
