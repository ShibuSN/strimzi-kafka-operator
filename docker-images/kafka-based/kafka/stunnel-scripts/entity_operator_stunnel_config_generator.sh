#!/usr/bin/env bash
set -e

# path were the Secret with EO certificates is mounted
ETO_CERTS_KEYS=/etc/eto-certs
# Combine all the certs in the cluster CA into one file
CA_CERTS=/tmp/cluster-ca.crt
for cert in /etc/tls-sidecar/cluster-ca-certs/*.crt; do
  sed -z '$ s/\n$//' "$cert" >> "$CA_CERTS"
  echo "" >> "$CA_CERTS"
done

echo "pid = /tmp/stunnel.pid"
echo "foreground = yes"
echo "debug = $TLS_SIDECAR_LOG_LEVEL"
echo "sslVersion = TLSv1.2"

cat <<-EOF
[zookeeper-2181]
client = yes
CAfile = ${CA_CERTS}
cert = ${ETO_CERTS_KEYS}/entity-topic-operator.crt
key = ${ETO_CERTS_KEYS}/entity-topic-operator.key
accept = 127.0.0.1:2181
connect = ${STRIMZI_ZOOKEEPER_CONNECT:-zookeeper-client:2181}
delay = yes
verify = 2

EOF
