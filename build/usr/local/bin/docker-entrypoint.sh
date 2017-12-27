#!/bin/sh

export WWW="$/var/www"
export ZEN="${WWW}/zen"

declare www_user=${www_user:-'www-data'}
declare www_group=${www_group:-'www-data'}
  
if [ "$1" = 'zen' ]; then
    www_user='nobody'
    www_group='nobody'
    sudo chown "${www_user}:${www_group}" -R /var/log 
    sudo chown "${www_user}:${www_group}" -R /var/www/photos/albums
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info
else
    exec $@
fi
