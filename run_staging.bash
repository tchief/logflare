#! /bin/bash

set -ex

export GOOGLE_APPLICATION_CREDENTIALS=/logflare/gcloud.json

sysctl -w net.ipv4.tcp_keepalive_time=60 net.ipv4.tcp_keepalive_intvl=60 net.ipv4.tcp_keepalive_probes=5

export MY_POD_IP=$(curl \
    -s "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" \
    -H "Metadata-Flavor: Google")

mix ecto.migrate

sleep 10

/logflare/_build/staging/rel/logflare/bin/logflare start