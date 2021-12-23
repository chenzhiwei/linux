# 生成 SSL 证书

推荐使用这个更简单并且无任何依赖的证书生成工具： https://github.com/chenzhiwei/certctl

## 概念

所谓 Root CA 就是用来签发证书的根证书，与 Root CA 对应的还有 Root key。这个 Root CA 是公共的证书，用户可以导入到自己浏览器里面，这样所有用这个 Root CA 签名的证书都能被浏览器信任了。Root key 是非常重要的私钥，证书机构全靠这个东西来赚钱呢，所以不能泄漏。

用户的证书生成方式是，用户先生成一个私钥和一个 CSR(Certificate Signing Request) 文件，然后把这个 CSR 文件提交给证书机构（比如 Lets Encrypt），然后证书机构用它的 Root CA certifcate 和 Root CA private key 来生成用户的证书。

Root CA 可以没有Subject Alternative Name字段，但是在Key Usage和Extended Key Usage里面必须有`CRL Sign, Certificate Sign, Digital Signature`和`TLS Web Client Authentication, TLS Web Server Authentication`。

### Key Usage

* digitalSignature
* contentCommitment
* keyEncipherment
* dataEncipherment
* keyAgreement
* keyCertSign
* cRLSign
* encipherOnly
* decipherOnly

### Extended Key Usage

* any
* serverAuth
* clientAuth
* codeSigning
* emailProtection
* IPSECEndSystem
* IPSECTunnel
* IPSECUser
* timeStamping
* OCSPSigning
* netscapeServerGatedCrypto
* microsoftServerGatedCrypto
* microsoftCommercialCodeSigning
* microsoftKernelCodeSigning

## Generate Self-signed Certificate

```
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days 36500 -keyout self-signed.key -out self-signed.crt \
    -subj "/C=CN/ST=Beijing/L=Haidian/O=Self-Signed Inc/CN=self-signed.com" \
    -addext "subjectAltName = DNS:*.self-signed.com,DNS:localhost,IP:127.0.0.1" \
    -addext "keyUsage = digitalSignature, keyEncipherment" \
    -addext "extendedKeyUsage = serverAuth, clientAuth"
```

## Generate Root CA

```
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days 36500 -keyout ca.key -out ca.crt \
    -subj "/C=CN/ST=Beijing/L=Haidian/O=Root Inc/CN=Root Inc" \
    -addext "keyUsage = digitalSignature, keyEncipherment, dataEncipherment, cRLSign, keyCertSign" \
    -addext "extendedKeyUsage = serverAuth, clientAuth"
```

## Generate Certificate Private Key

```
openssl genrsa -out server.key 4096
```

## Generate Certificate Signing Request

```
openssl req -new -key server.key -out server.csr \
    -subj "/C=CN/ST=Beijing/L=Haidian/O=MixHub Inc/CN=mixhub.cn" \
    -addext "basicConstraints = critical,CA:FALSE" \
    -addext "keyUsage = digitalSignature,keyEncipherment" \
    -addext "extendedKeyUsage = serverAuth,clientAuth" \
    -addext "subjectAltName = DNS:mixhub.cn,DNS:*.mixhub.cn"
```

## Sign Certificate with CSR by Root CA

```
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -extensions v3_req \
    -extfile <(printf "[v3_req]\nbasicConstraints=critical,CA:FALSE\nextendedKeyUsage=serverAuth,clientAuth\nkeyUsage=digitalSignature,keyEncipherment\nsubjectAltName=DNS:mixhub.cn,DNS:*.mixhub.cn")
```

## Convert ASCII format to PEM format

```
openssl rsa -in server.key -outform PEM -out key.pem

openssl x509 -in server.crt -outform PEM -out cert.pem
```

## Convert certificate and key to pkcs12 format

```
openssl pkcs12 -export -in server.crt -inkey server.key -out server.pkcs12 -passout pass:abc123
```

## Generate Java Key Store files

```
# generate truststore
keytool -importcert -keystore truststore.jks -file ca.crt -noprompt -storepass abc123

# generate keystore
keytool -importcert -keystore keystore.jks -file ca.crt -noprompt -storepass abc123
keytool -importkeystore -destkeystore keystore.jks -deststorepass abc123 -srckeystore server.pkcs12 -srcstorepass abc123

# view keystore entries
keytool -list -v -keystore keystore.jks -storepass abc123
keytool -list -v -keystore server.pkcs12 -storepass abc123
```

## Create the Server Key file

> Remove `-des3` if you do not want a password

```
$ openssl genrsa -des3 -out server.key 2048
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
openssl req -noout -text -in server.csr
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
