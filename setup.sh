#!/bin/bash

if [ -S /var/run/docker.sock ]; then
    sudo chown -R claude:claude /var/run/docker.sock
fi

exec "$@"