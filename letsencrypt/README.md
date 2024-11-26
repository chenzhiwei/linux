# Generate Let's Encrypt certificate

## Install acme.sh

```
curl  https://get.acme.sh | sh
```

## Generate TXT record

```
acme.sh --issue --dns -d mixhub.cn -d '*.mixhub.cn' --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

After this command you will get a subdomain and TXT record, then update your DNS record according to this.

## Generate certificate

```
acme.sh --renew --dns -d mixhub.cn -d '*.mixhub.cn' --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

You will get something like this:

```
[Thu Aug 16 08:04:20 EDT 2018] Your cert is in  /root/.acme.sh/mixhub.cn/mixhub.cn.cer
[Thu Aug 16 08:04:20 EDT 2018] Your cert key is in  /root/.acme.sh/mixhub.cn/mixhub.cn.key
[Thu Aug 16 08:04:20 EDT 2018] The intermediate CA cert is in  /root/.acme.sh/mixhub.cn/ca.cer
[Thu Aug 16 08:04:20 EDT 2018] And the full chain certs is there:  /root/.acme.sh/mixhub.cn/fullchain.cer
```

## Generate certificate in DNS alias mode

* domain: mixhub.cn
* alias domain: mixhub-alias.cn

1. setup domain CNAME to alias domain

    ```
    _acme-challenge.mixhub.cn
        => _acme-challenge.mixhub-alias.cn
    ```

2. Use DNS API

    * CloudFlare

        export CF_Token=xxx
        export CF_Account_ID=xxx
        acme.sh --dns dns_cf

    * Digital Ocean

        export DO_API_KEY=xxx
        acme.sh --dns dns_dgon

3. Issue a certificate

    ```
    acme.sh --issue \
        --dns dns_dgon \
        --server letsencrypt \
        --challenge-alias mixhub-alias.cn \
        -d mixhub.cn -d '*.mixhub.cn'
    ```

4. Renew a certificate

    ```
    acme.sh --renew \
        --dns dns_dgon \
        --server letsencrypt \
        --challenge-alias mixhub-alias.cn \
        -d mixhub.cn -d '*.mixhub.cn'
    ```


## Setup Docker registry

```
mkdir registry.mixhub.cn && cd registry.mixhub.cn
mkdir auth certs registry

cp /root/.acme.sh/mixhub.cn/fullchain.cer certs/domain.crt
cp /root/.acme.sh/mixhub.cn/mixhub.cn.key certs/domain.key

docker run --rm --entrypoint htpasswd registry:2 -Bbn username password > auth/htpasswd

docker run -d \
    --restart=always \
    --name registry \
    -p 443:443 \
    -v $(pwd)/auth:/auth \
    -v $(pwd)/certs:/certs \
    -v $(pwd)/registry:/var/lib/registry \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -e REGISTRY_AUTH=htpasswd \
    -e REGISTRY_AUTH_HTPASSWD_REALM=Mixhub-Realm \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    registry:2
```
