#!/bin/bash

mkdir -p /var/lib/nginx

[[ -f /etc/conf.d/nginx/default.conf ]]  && rm /etc/nginx/conf.d/default.conf
if [[ -h /var/lib/nginx/logs ]]; then
    rm /var/lib/nginx/logs
    ln -s /var/log /var/lib/nginx/logs
fi

[[ -d /var/nginx/client_body_temp ]] || mkdir -p /var/nginx/client_body_temp
[[ -d /run/nginx ]]                  || mkdir -p /run/nginx
