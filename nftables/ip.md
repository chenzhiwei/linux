# iproute


## Create tun

```
ip tuntap add mode tun name tun1
ip link set tun1 up

# set owner to alice
ip tuntap add mode tun user alice name tun1

# route packets to tun
ip route add 198.18.0.0/15 dev tun1
```


## route packets with fwmark policy

```
# Set default gateway with a table
# packets with table 115 will be handled by tun1
ip route add default dev tun1 table 115

# packets with fwmark 115 go to table 115 then handled by tun1
ip rule add fwmark 115 lookup 115

# test the rule policy
ip route get 1.1.1.1 mark 115

# nftables accept tun1 packets
nft add rule ip test local iif tun1 accept

# nftables mark other packets
nft add rule ip test local meta mark 115
```
