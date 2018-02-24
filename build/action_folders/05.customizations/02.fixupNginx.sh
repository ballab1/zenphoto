#!/bin/bash

mkdir -p /var/lib/nginx

[ -f /etc/conf.d/nginx/default.conf ]  && rm /etc/nginx/conf.d/default.conf
if [ -h /var/lib/nginx/logs ]; then
    rm /var/lib/nginx/logs
    ln -s /var/log /var/lib/nginx/logs
fi

[ -d /run/nginx ]                  || mkdir -p /run/nginx
[ -d /var/nginx/client_body_temp ] || mkdir -p /var/nginx/client_body_temp
[ -d /var/nginx/fastcgi_temp ]     || mkdir -p /var/nginx/fastcgi_temp
[ -d /var/nginx/proxy_temp ]       || mkdir -p /var/nginx/proxy_temp
[ -d /var/nginx/scgi_temp ]        || mkdir -p /var/nginx/scgi_temp
[ -d /var/nginx/uwsgi_temp ]       || mkdir -p /var/nginx/uwsgi_temp

