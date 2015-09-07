# 生成 SSL 证书

## Create the Server Key

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

## Sign your SSL Certificate

```
$ openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

## Import the crt file

```
# apt-get install libnss3-tools
# yum install nss-tools
# cat server.crt | certutil -d sql:/etc/pki/nssdb -A -t "P,," -n my.example.com
# certutil -d sql:/etc/pki/nssdb -L
# certutil -d sql:/etc/pki/nssdb -L -n my.example.com
```
