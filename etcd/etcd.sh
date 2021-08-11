#!/bin/bash

set -e # exit on error

PKI_DIR=/var/lib/etcd-container/pki
DATA_DIR=/var/lib/etcd-container/etcd

mkdir -p $PKI_DIR $DATA_DIR

ETCD_IMAGE="quay.io/coreos/etcd:v3.5.0"

## Etcd Info
SERVER_NAME=etcd-host0
SERVER_IP=192.168.119.22
SANS="DNS:localhost,DNS:$SERVER_NAME,IP:127.0.0.1,IP:$SERVER_IP"

##############################
## Generate Etcd certificates
##############################
function etcd_ca() {
    cd $PKI_DIR
    openssl req -newkey rsa:4096 -sha256 -nodes -keyout ca.key -x509 -days 36500 -out ca.crt -subj "/CN=etcd-ca" \
        -addext "keyUsage = critical, digitalSignature, keyEncipherment, dataEncipherment, cRLSign, keyCertSign"
}

function etcd_server_crt() {
    cd $PKI_DIR
    openssl genrsa -out server.key 4096
    openssl req -new -key server.key -out server.csr -subj "/CN=$SERVER_NAME"
    openssl x509 -req -days 730 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -extensions v3_req \
        -extfile <(printf "[v3_req]\nbasicConstraints=critical,CA:FALSE\nextendedKeyUsage=serverAuth,clientAuth\nkeyUsage=critical,digitalSignature,keyEncipherment\nauthorityKeyIdentifier=keyid,issuer\nsubjectAltName=$SANS")
}

function etcd_peer_crt() {
    cd $PKI_DIR
    openssl genrsa -out peer.key 4096
    openssl req -new -key peer.key -out peer.csr -subj "/CN=$SERVER_NAME"
    openssl x509 -req -days 730 -in peer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out peer.crt -extensions v3_req \
        -extfile <(printf "[v3_req]\nbasicConstraints=critical,CA:FALSE\nextendedKeyUsage=serverAuth,clientAuth\nkeyUsage=critical,digitalSignature,keyEncipherment\nauthorityKeyIdentifier=keyid,issuer\nsubjectAltName=$SANS")
}

function etcd_client_crt() {
    cd $PKI_DIR
    openssl genrsa -out client.key 4096
    openssl req -new -key client.key -out client.csr -subj "/CN=etcd-client"
    openssl x509 -req -days 730 -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -extensions v3_req \
        -extfile <(printf "[v3_req]\nbasicConstraints=critical,CA:FALSE\nextendedKeyUsage=clientAuth\nkeyUsage=critical,digitalSignature,keyEncipherment\nauthorityKeyIdentifier=keyid,issuer")
}

##############################
## Etcd start command
##############################
function etcd_start() {
    docker run -d --network host --name etcd -v $DATA_DIR:/var/lib/etcd -v $PKI_DIR:/etc/etcd/pki $ETCD_IMAGE etcd \
        --name=$SERVER_NAME \
        --data-dir=/var/lib/etcd \
        --snapshot-count=10000 \
        --client-cert-auth=true \
        --trusted-ca-file=/etc/etcd/pki/ca.crt \
        --key-file=/etc/etcd/pki/server.key \
        --cert-file=/etc/etcd/pki/server.crt \
        --listen-client-urls=https://127.0.0.1:2379,https://$SERVER_IP:2379 \
        --advertise-client-urls=https://$SERVER_IP:2379 \
        --peer-client-cert-auth=true \
        --peer-trusted-ca-file=/etc/etcd/pki/ca.crt \
        --peer-key-file=/etc/etcd/pki/peer.key\
        --peer-cert-file=/etc/etcd/pki/peer.crt \
        --listen-peer-urls=https://$SERVER_IP:2380 \
        --initial-advertise-peer-urls=https://$SERVER_IP:2380 \
        --initial-cluster=$SERVER_NAME=https://$SERVER_IP:2380 \
        --listen-metrics-urls=http://127.0.0.1:2381
}


etcd_ca
etcd_server_crt
etcd_client_crt
etcd_peer_crt
etcd_start
