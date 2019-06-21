#!/bin/bash
#
# This script is used to setup a TLS registry with auth enabled easily,
# you can customize following variables to meet your requirement:
#
#   SERVER_ADDRESS  # Change this to your server IP address or FQDN
#   SERVER_PORT     # Optional, the port of the registry
#   REGISTRY_DIR    # Optional, the directory to store your registry images
#   REGISTRY_IMAGE  # Optional, the registry image
#   REGISTRY_USER   # Optional, the username to login registry
#   REGISTRY_PASS   # Optional, the password to login registry
#
# Login to registry by:
#
#   docker login -u admin -p admin $SERVER_ADDRESS:$SERVER_PORT
#   docker tag local-image:1.2 $SERVER_ADDRESS:$SERVER_PORT/project/local-image:1.2
#   docker push $SERVER_ADDRESS:$SERVER_PORT/project/local-image:1.2
#   docker pull $SERVER_ADDRESS:$SERVER_PORT/project/local-image:1.2
#
# If you want to use this registry on other nodes, please copy the script file
# docker-trust-script.sh to the target nodes and execute it, then you can use this registry
# docker-trust-script.sh will be generated after you setup the registry
#
# If you want to uninstall this registry, just run following command:
#
#   bash docker-registry-setup.sh uninstall
#
# NOTE: Please ignore errors in setup or uninstall, if you can login to this regitry
#       then it means you setup the registry correctly.
#

SERVER_PORT=443
SERVER_ADDRESS=1.1.1.1
REGISTRY_DIR=/var/lib/docker-registry
REGISTRY_IMAGE=registry:2
REGISTRY_USER=admin
REGISTRY_PASS=admin

if [[ "$SERVER_ADDRESS" =~ ^[0-9.]+$ ]]; then
    SAN="IP:$SERVER_ADDRESS"
else
    SAN="DNS:$SERVER_ADDRESS"
fi

function gen_user() {
    mkdir -p $REGISTRY_DIR/auth
    docker run --rm --entrypoint htpasswd $REGISTRY_IMAGE -Bbn $REGISTRY_USER $REGISTRY_PASS > $REGISTRY_DIR/auth/htpasswd
}

function gen_cert() {
    mkdir -p $REGISTRY_DIR/certs
    cd $REGISTRY_DIR/certs
    if ls domain.key domain.csr domain.crt; then
        cd -
        return 0
    fi
    openssl genrsa -out domain.key 4096
    openssl req -new -key domain.key -out domain.csr -subj "/C=US/ST=California/L=Los Angeles/O=Docker Registry/CN=$SERVER_ADDRESS"
    openssl x509 -req -days 36500 -in domain.csr -signkey domain.key -out domain.crt -extensions SAN -extfile <(printf "[SAN]\nsubjectAltName=$SAN")
    cd -
}

function gen_trust_script() {
    cat <<EOF > docker-trust-script.sh
#!/bin/bash
mkdir -p "/etc/docker/certs.d/$SERVER_ADDRESS:$SERVER_PORT"
echo "$(cat $REGISTRY_DIR/certs/domain.crt)" > "/etc/docker/certs.d/$SERVER_ADDRESS:$SERVER_PORT/ca.crt"
if [[ "$SERVER_PORT" == "443" ]]; then
    mkdir -p "/etc/docker/certs.d/$SERVER_ADDRESS"
    echo "$(cat $REGISTRY_DIR/certs/domain.crt)" > "/etc/docker/certs.d/$SERVER_ADDRESS/ca.crt"
fi
EOF

    bash docker-trust-script.sh
}

function start_registry() {
    cd $REGISTRY_DIR
    docker run -d \
        --restart=always \
        --name docker-registry \
        -p $SERVER_PORT:443 \
        -v $(pwd)/auth:/auth \
        -v $(pwd)/certs:/certs \
        -v $(pwd)/data:/var/lib/registry \
        -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
        -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
        -e REGISTRY_AUTH=htpasswd \
        -e REGISTRY_AUTH_HTPASSWD_REALM=Docker-Registry-Realm \
        -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
        $REGISTRY_IMAGE
    cd -
}

if [[ "$1" == "uninstall" ]]; then
    docker stop docker-registry
    docker rm -f docker-registry
    cd $REGISTRY_DIR && rm -rf auth certs data
else
    gen_user
    gen_cert
    gen_trust_script
    start_registry
fi
