# 生成 SSL 证书

## 概念

所谓 Root CA 就是用来签发证书的根证书，与 Root CA 对应的还有 Root key。这个 Root CA 是公共的证书，用户可以导入到自己浏览器里面，这样所有用这个 Root CA 签名的证书都能被浏览器信任了。Root key 是非常重要的私钥，证书机构全靠这个东西来赚钱呢，所以不能泄漏。

用户的证书生成方式是，用户先生成一个私钥和一个 CSR(Certificate Signing Request) 文件，然后把这个 CSR 文件提交给证书机构（比如 Lets Encrypt），然后证书机构用它的 Root CA 和 Root key 来生成用户的证书。

### 生成 Root CA 和 Root key


1. 生成 Root key

    ```
    openssl genrsa -out root.key 2048

    ```

2. 用 Root key 来生成 CSR

    ```
    openssl req -new -key root.key -out root.csr
    ```

3. 用 Root key 和 Root csr 来生成证书

    ```
    openssl x509 -req -days 36500 -in root.csr -signkey root.key -out root.crt
    ```

4. 用 Root CA 和 Root key 生成用户的证书

    1. 生成用户的 key 和 csr

        ```
        openssl genrsa -out user.key 2048
        openssl req -new -key user.key -out user.csr
        ```

    2. 给用户签发证书

        ```
        openssl x509 -req -in user.csr -extensions v3_usr -CA root.crt -CAkey root.key -CAcreateserial -out user.crt
        ```

    3. 在浏览器里导入 root.crt ，然后在 HTTP Server 里配置 user.key 和 user.crt，然后就不会有证书错误了。

## Single command to generate self-signed certifcate

```
openssl req -newkey rsa:4096 -sha256 -nodes -keyout your-domain.com.key -x509 -days 36500 -out your-domain.com.crt -subj "/C=US/ST=California/L=Los Angeles/O=Your Domain Inc/CN=your-domain.com"
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
$ openssl x509 -text -noout -in server.crt
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
