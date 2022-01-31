# nftables

## Basic Commands

* nftables family: ip, ip6, inet, arp, bridge
* chain type: filter, route, nat
* hook type: prerouting, input, forward, output, postrouting
* policy type: accept, drop
* priority_value: srcnat(100), security(50), filter(0), dstnat(-100), mangle(-150), raw(-300)

### List tables/ruleset

```
# list all tables
nft list tables

nft list table ip clash
nft list chain ip clash local

# list ruleset
nft list ruleset
```

### Create table/chain

* nft add table table_family table_name

    ```
    nft add table ip clash
    ```

* nft add chain table_family table_name chain_name '{type chain_type hook hook_type priority priority_value; policy policy_type}'

    ```
    nft add chain ip clash local '{type route hook output priority filter; policy accept;}'
    ```

### Create rules

* nft add rule table_family table_name chain_name expression statement

* expression

    ```
    meta:
      mark <fwmark value>
      oif <output interface index/name>
      iif <input interface index/name>
      iiftype <input interface type>
      skuid <uid associated with originating socket>
      skgid <gid associated with originating socket>
      cgroup <control group id>

    ip:
      protocol <protocol>
      daddr <destination address>
      saddr <source address>

    ip6:
      daddr <destination address>
      saddr <source address>

    tcp:
      tcp {sport | dport | sequence | ackseq | doff | reserved | flags | window | checksum | urgptr}

    udp:
      udp {sport | dport | length | checksum}

    ct:
      ct {state | direction | status | mark | expiration | helper | label}
      state <new | established | related | invalid>
    ```

* statement

    ```
    verdict statement:
      accept, drop, queue, continue, return, jump, goto

    reject statement:
      reject
      reject with tcp reset

    conntrack statement:
      ct {mark | event | label | zone} set value

    meta statement:
      meta {mark | priority | pkttype | nftrace} set value

    nat statement:
      snat to address [:port]
      dnat to address [:port]
      masquerade to [:port]
      redirect to [:port]
    ```

* Accept requests from interface

    ```
    nft add rule ip test local iif "utun" accept
    ```

* Accept requests to IP CIDR

    ```
    nft add rule ip test local ip daddr {10.0.0.0/8, 127.0.0.0/8} accept
    ```

* Accept requests not equal to IP protocols

    ```
    nft add rule ip test local ip protocol != { tcp, udp } accept
    ```

* NAT requests

    ```
    nft add rule ip test local ip daddr 223.5.5.5 udp dport 53 dnat 127.0.0.153:53
    ```
* Set fwmark

    ```
    # set fwmark to packet
    nft add rule ip test local ip daddr 223.6.6.6 udp dport 53 meta mark set 0x00012345

    # https://lwn.net/Articles/594698/
    # set the conntrack mark to the packet mark
    nft filter input ct mark set mark


    # set the packet mark to the conntrack mark
    nft filter output mark set ct mark


    # set the conntrack mark to the value 0x1.
    nft filter output ct mark set 0x1

    # https://wiki.nftables.org/wiki-nftables/index.php/Setting_packet_metainformation
    nft add rule filter forward meta mark set 1

    # mark is store in the conntrack entry associated with the flow
    nft add rule filter forward ct mark set mark

    # the conntrack mark is stored in the packet
    nft add rule filter forward meta mark set ct mark
    ```

## Routing

* Routing local traffic with `output` hook

    ```
    # 2.2.2.2:anyp-port --> 123.126.45.68:any-port
    nft add rule ip nat OUTPUT ip daddr 2.2.2.2 dnat 123.126.45.68

    # udp 223.5.5.5:53 --> 127.0.0.153:53
    nft add rule ip nat OUTPUT ip daddr 223.5.5.5 udp dport 53 dnat 127.0.0.153:53
    ```

* Routing forward traffic with `prerouting` hook

    ```
    nft add rule ip nat PREROUTING ip daddr 2.2.2.2 dnat 123.126.45.68
    ```

## File

```
nft -f nftable.conf
```
