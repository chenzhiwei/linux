# 生成 SSL 证书

推荐使用这个更简单并且无任何依赖的证书生成工具： https://github.com/chenzhiwei/certctl

## 概念

所谓 Root CA 就是用来签发证书的根证书，与 Root CA 对应的还有 Root key。这个 Root CA 是公共的证书，用户可以导入到自己浏览器里面，这样所有用这个 Root CA 签名的证书都能被浏览器信任了。Root key 是非常重要的私钥，证书机构全靠这个东西来赚钱呢，所以不能泄漏。

用户的证书生成方式是，用户先生成一个私钥和一个 CSR(Certificate Signing Request) 文件，然后把这个 CSR 文件提交给证书机构（比如 Lets Encrypt），然后证书机构用它的 Root CA 和 Root key 来生成用户的证书。


## 用 Root CA 签证书


1. 生成 Root CA

    ```
    openssl req -newkey rsa:4096 -sha256 -nodes -keyout ca.key -x509 -days 36500 -out ca.crt \
        -subj "/C=US/ST=California/L=Los Angeles/O=Root Inc/CN=root-ca" \
        -addext "keyUsage = critical, digitalSignature, keyEncipherment, dataEncipherment, cRLSign, keyCertSign"
    ```

2. 用 Root CA 签发普通 web server 证书

    如果需要 Web Server Authentication 或 Web Client Authentication 的话，就添加相应的 extensions 就行了。

    ```
    openssl genrsa -out mixhub.cn.key 4096

    openssl req -new -key mixhub.cn.key -out mixhub.cn.csr \
        -subj "/C=US/ST=California/L=Los Angeles/O=MixHub Inc/CN=mixhub.cn" \

    openssl x509 -req -days 730 -in mixhub.cn.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out mixhub.cn.crt -extensions v3_req \
        -extfile <(printf "[v3_req]\nbasicConstraints=critical,CA:FALSE\nextendedKeyUsage=serverAuth,clientAuth\nkeyUsage=critical,digitalSignature,keyEncipherment\nauthorityKeyIdentifier=keyid,issuer\nsubjectAltName=DNS:mixhub.cn,DNS:
*.mixhub.cn")
    ```

    看文档中有写`openssl x509`会支持`-copy_extensions copy`，这样就可以在生成 CSR 的时候加上 extensions ，然后在生成证书的命令就非常简单了，但是目前还没实现。如果实现的话可以用以下方法：

    ```
    openssl genrsa -out mixhub.cn.key 4096

    openssl req -new -key mixhub.cn.key -out mixhub.cn.csr \
        -subj "/C=US/ST=California/L=Los Angeles/O=MixHub Inc/CN=mixhub.cn" \
        -addext "basicConstraints = critical,CA:FALSE" \
        -addext "keyUsage = critical,digitalSignature,keyEncipherment" \
        -addext "extendedKeyUsage = serverAuth,clientAuth" \
        -addext "subjectAltName = DNS:mixhub.cn,DNS:*.mixhub.cn"

    # this should be work in future version of openssl
    openssl x509 -req -days 730 -in mixhub.cn.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out mixhub.cn.crt -copy_extensions copy
    ```

## Generate self-signed certifcate for web server

```
openssl req -newkey rsa:4096 -sha256 -nodes -keyout your-domain.com.key -x509 -days 36500 -out your-domain.com.crt \
    -subj "/C=US/ST=California/L=Los Angeles/O=Your Domain Inc/CN=your-domain.com" \
    -addext "subjectAltName = DNS:your-domain.com,DNS:www.your-domain.com,IP:127.0.0.1"
```


## Convert ASCII format to PEM format

```
openssl rsa -in server.key -outform PEM -out key.pem

openssl x509 -in server.crt -outform PEM -out cert.pem
```

## Create the Server Key file

> Remove `-des3` if you do not want a password

```
$ openssl genrsa -des3 -out server.key 2048
```

## Create Certificate Signing Request

```
$ openssl req -new -key server.key -out server.csr
```

## Remove the Passphrase

```
$ cp server.key server.key.org
$ openssl rsa -in server.key.org -out server.key
```

## Export RSA Public Key

```
openssl rsa -in server.key -outform PEM -pubout -out server.pubkey
```

## Self-sign your Server Key file

> `server.crt` is your certificate file

```
$ openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

## Get the CSR info

```
openssl req -noout -text -in mixhub.cn.csr
```

## Get the certificate info

```
openssl x509 -text -noout -in server.crt

openssl s_client -connect baidu.com:443 2>/dev/null | openssl x509 -noout -text
```

## Check if the certificate is signed by a root ca

```
openssl verify -verbose -CAfile ca.crt user.crt
```

## After setup an HTTP server

```
$ curl --cacert server.crt http://your_host
```

## Make System trusted your self-signed certificate

### RHEL / CentOS

```
# yum install nss-tools
# cat server.crt | certutil -d sql:/etc/pki/nssdb -A -t "P,," -n your_host
# # certutil -d sql:/etc/pki/nssdb -A -t "P,," -n your_host -i server.crt
# certutil -d sql:/etc/pki/nssdb -L
# certutil -d sql:/etc/pki/nssdb -L -n your_host
# curl https://your_host
```


### Ubuntu

> Ubuntu does not use `/etc/pki/nssdb`

```
# apt install libnss3-tools
# certutil -d sql:/etc/pki/nssdb -L
```

The right method:

```
# cp server.crt /usr/share/ca-certificates/your_host.crt
# vim /etc/ca-certificates.conf # Append `your_host.crt` to the end
# update-ca-certificates
# curl https://your_host
```
