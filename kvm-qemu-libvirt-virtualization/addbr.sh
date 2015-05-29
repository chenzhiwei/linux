#!/bin/bash
#
# After executing this script, you can use br0/br1 to create VMs.
# And you should set the VMs' default gateway to 192.168.0.1
#

brctl show br0 || brctl addbr br0
brctl show br1 || brctl addbr br1

ip addr add 192.168.0.1/24 brd 192.168.0.255 dev br0
ip addr add 10.0.0.1/24 brd 10.0.0.255 dev br1

ip link set br0 up
ip link set br1 up

iptables -t nat -A POSTROUTING -s 192.168.0.0/24 ! -d 192.168.0.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 ! -d 192.168.0.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 ! -d 192.168.0.0/24 -j MASQUERADE
iptables -t mangle -A POSTROUTING -o br0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
iptables -t filter -A INPUT -i br0 -p udp -m udp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -i br0 -p tcp -m tcp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -i br0 -p udp -m udp --dport 67 -j ACCEPT
iptables -t filter -A INPUT -i br0 -p tcp -m tcp --dport 67 -j ACCEPT
iptables -t filter -A FORWARD -d 192.168.0.0/24 -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A FORWARD -s 192.168.0.0/24 -i br0 -j ACCEPT
iptables -t filter -A FORWARD -i br0 -o br0 -j ACCEPT
iptables -t filter -A FORWARD -o br0 -j REJECT --reject-with icmp-port-unreachable
iptables -t filter -A FORWARD -i br0 -j REJECT --reject-with icmp-port-unreachable
