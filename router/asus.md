# Asus Router

## Setting guest wifi password

```
nvram get wl0.1_wpa_psk
nvram set wl0.1_wpa_psk=wifi-password
```

## DDns Setting

DNSPod API:

* /jffs/scripts/ddns-start

    ```
    #!/bin/sh

    IP=$1
    TOKEN=DNSPOD_TOKEN
    DOMAIN=DNSPOD_DOMAIN_ID
    RECORD=DNSPOD_DOMAIN_RECORD
    SUBDOMAIN=asus
    EMAIL=xxx@abc.com

    curl -fsk -m 3 -X POST \
         -A "DDNS Client/1.0.0 ($EMAIL)" \
         -d "login_token=$TOKEN&format=json&domain_id=$DOMAIN&record_id=$RECORD&record_line_id=0&sub_domain=$SUBDOMAIN&value=$IP" \
         https://dnsapi.cn/Record.Ddns

    /sbin/ddns_custom_updated 1
    ```

## Reference

* https://github.com/RMerl/asuswrt-merlin/wiki
