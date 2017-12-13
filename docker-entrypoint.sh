#!/bin/sh

export WWW="$/var/www"
export ZEN="${WWW}/zen"

if [ "$1" = 'zen' ]; then
    chown nobody:nobody -R /var/log/*
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info
else
    exec $@
fi
