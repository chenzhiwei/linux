# 生成 SSL 证书

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
