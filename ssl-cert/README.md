# 生成 SSL 证书

## 概念

所谓 Root CA 就是用来签发证书的根证书，与 Root CA 对应的还有 Root key。这个 Root CA 是公共的证书，用户可以导入到自己浏览器里面，这样所有用这个 Root CA 签名的证书都能被浏览器信任了。Root key 是非常重要的私钥，证书机构全靠这个东西来赚钱呢，所以不能泄漏。

用户的证书生成方式是，用户先生成一个私钥和一个 CSR(Certificate Signing Request) 文件，然后把这个 CSR 文件提交给证书机构（比如 Lets Encrypt），然后证书机构用它的 Root CA 和 Root key 来生成用户的证书。


## 用 Root CA 签证书


1. 生成 Root CA

    ```
    openssl req -newkey rsa:4096 -sha256 -nodes -keyout root.key -x509 -days 36500 -out root.crt -subj "/C=US/ST=California/L=Los Angeles/O=Root Inc/CN=root"

    ```

2. 用 Root CA 签发用户证书

    1. 生成用户的 key 和 csr

        ```
        openssl genrsa -out domain.key 4096
        openssl req -new -key domain.key -out domain.csr -subj "/C=US/ST=California/L=Los Angeles/O=Domain Inc/CN=domain.com"
        ```

    2. 给用户签发证书

        ```
        openssl x509 -req -days 730 -in domain.csr -CA root.crt -CAkey root.key -CAcreateserial -out domain.crt -extensions v3_usr

        openssl x509 -req -days 730 -in domain.csr -CA root.crt -CAkey root.key -CAcreateserial -out domain.crt -extensions SAN -extfile <(printf "[SAN]\nsubjectAltName=DNS:example.com,DNS:www.example.com")
        ```

    3. 在浏览器里导入 root.crt ，然后在 HTTP Server 里配置 domain.key 和 domain.crt，然后就不会有证书错误了。


## Single command to generate self-signed certifcate

```
openssl req -newkey rsa:4096 -sha256 -nodes -keyout your-domain.com.key -x509 -days 36500 -out your-domain.com.crt -subj "/C=US/ST=California/L=Los Angeles/O=Your Domain Inc/CN=your-domain.com"
```

## Generate self-signed certificate with SAN

```
openssl genrsa -out domain.key 4096
openssl req -new -key domain.key -out domain.csr -subj "/C=US/ST=California/L=Los Angeles/O=Domain Inc/CN=domain.com"
openssl x509 -req -days 36500 -in domain.csr -signkey domain.key -out domain.crt -extensions SAN -extfile <(printf "[SAN]\nsubjectAltName=DNS:domain.com")
```

You can ignore the following steps.

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

## Self-sign your Server Key file

> `server.crt` is your certificate file

```
$ openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

## Get the certificate info

```
openssl x509 -text -noout -in server.crt

openssl s_client -connect baidu.com:443 2>/dev/null | openssl x509 -noout -text
```

## Check if the certificate is signed by a root ca

```
openssl verify -verbose -CAfile root.crt user.crt
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
