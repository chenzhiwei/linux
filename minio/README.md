# Minio

MinIO offers high-performance, S3 compatible multi-cloud object storage.


## Deploy

Minio + Nginx(TLS) containerization deployment.

```
docker run -d --name nginx -p 8000:8000 -p 8001:8001 \
    -v /etc/nginx/certs:/etc/nginx/certs:z \
    -v /etc/nginx/conf.d:/etc/nginx/conf.d:z \
    docker.io/siji/nginx:alpine

docker run -d --name minio --network=container:nginx \
    -e MINIO_ROOT_USER=minio -e MINIO_ROOT_PASSWORD=minio123 \
    -v /var/lib/minio:/data:z docker.io/siji/minio:latest \
    minio server /data --address ":9000" --console-address ":9001"
```

If you are using Podman, you can simply run:

```
podman play kube k8s-deployment.yaml
```


## Use

```
mc alias set minio https://192.168.122.10:8000/ minio minio123 --insecure

mc mb minio/mybucket --insecure
mc ls minio --insecure

mc cp README.md minio/mybucket/some/dir/README.md --insecure
```

```
ACCESS_KEY=minio
SECRET_KEY=minio123
HOST=192.168.122.10:8000

target_file=/mybucket/some/dir/README.md
content_type=application/octet-stream
date=$(date -R)
_signature="PUT\n\n${content_type}\n${date}\n${target_file}"
signature=$(echo -en ${_signature} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

curl -v -k -X PUT -T README.md \
    -H "Date: ${date}" \
    -H "Content-Type: ${content_type}" \
    -H "Authorization: AWS ${ACCESS_KEY}:${signature}" \
    https://${HOST}${target_file}
```


## User & Policy

ARNs: `arn:partition:service:region:account:resource`
Actions: https://docs.min.io/minio/baremetal/security/minio-identity-management/policy-based-access-control.html#supported-s3-policy-actions

### Bucket CRUD


```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:DeleteBucket",
                "s3:ForceDeleteBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
```

### Bucket ReadOnly

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::/mybucket/*"
            ]
        }
    ]
}
```
