#!/bin/bash -x

env | sort

declare www_user=${www_user:-'www-data'}
declare www_group=${www_group:-'www-data'}

touch /var/log/php5-fpm.log
chmod 666 /var/log/php5-fpm.log 

  
www_user='nobody'
www_group='nobody'
chown "${www_user}:${www_group}" -R /var/log 
chown "${www_user}:${www_group}" -R "${WWW}/albums"
