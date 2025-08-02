#!/bin/bash

if [ -S /var/run/docker.sock ]; then
    sudo chown -R claude:claude /var/run/docker.sock
fi

screen -dmS socat-figma-proxy socat TCP-LISTEN:3845,bind=127.0.0.1,fork TCP:host.docker.internal:3845

exec "$@"