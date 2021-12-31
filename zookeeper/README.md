# Zookeeper

## Server Start

```
export JVM_OPTS="-Djava.security.auth.login.config=/etc/zookeeper/zookeeper.jaas.conf"
zookeeper-server-start.sh /etc/zookeeper/zookeeper.properties
```

## Client Use

```
export JVM_OPTS="-Djava.security.auth.login.config=/etc/zookeeper/zookeeper-client.jaas.conf"

kafka-configs.sh --zookeeper zk1-host.local:2182 \
    --zk-tls-config-file zookeeper-client.properties \
    --alter --add-config 'SCRAM-SHA-256=[password=password-holder]' \
    --entity-type users --entity-name admin
```

## Certificates

* zookeeper.server.keystore.jks

    The Zookeeper server certificate that include serverAuth in extended key usage.

* zookeeper.server.truststore.jks

    The Zookeeper server CA certificate.

* zookeeper.quorum.keystore.jks

    The Zookeeper quorum server certificate that include serverAuth and clientAuth in extended key usage.

* zookeeper.quorum.truststore.jks

    The Zookeeper quorum server CA certificate.

* zookeeper.client.keystore.jks

    The Zookeeper client authentication certificate for Zookeeper server.

* zookeeper.client.truststore.jks

    The Zookeeper client authentication CA certificate.
