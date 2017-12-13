#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose

declare TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  


# zenphoto
declare -r ZEN_VERSION=${ZEN_VERSION:-'1.4.14'}
declare -r ZEN_FILE="zenphoto-${ZEN_VERSION}.tar.gz"
declare -r ZEN_URL="https://github.com/zenphoto/zenphoto/archive/zenphoto-${ZEN_VERSION}.tar.gz"
declare -r ZEN_SHA256="ecd0efac214e60be9ed339977d7be946a34f6eeb5fe2adc6c20fa42bd450ebff"

# PHP
declare -r PHP_VERSION=${PHP_VERSION:-'5.6.31'}    
declare -r PHP_FILE="php-${PHP_VERSION}.tar.gz"
declare -r PHP_URL="http://us2.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror"
declare -r PHP_SHA256="6687ed2f09150b2ad6b3780ff89715891f83a9c331e69c90241ef699dec4c43f"


#directories
declare WWW=/var/www/zen

#  groups/users
declare www_user=${www_user:-'www-data'}
declare www_uid=${www_uid:-82}
declare www_group=${www_group:-'www-data'}
declare www_gid=${www_gid:-82}


# global exceptions
declare -i dying=0
declare -i pipe_error=0


#----------------------------------------------------------------------------
# Exit on any error
function catch_error() {
    echo "ERROR: an unknown error occurred at $BASH_SOURCE:$BASH_LINENO" >&2
}

#----------------------------------------------------------------------------
# Detect when build is aborted
function catch_int() {
    die "${BASH_SOURCE[0]} has been aborted with SIGINT (Ctrl-C)"
}

#----------------------------------------------------------------------------
function catch_pipe() {
    pipe_error+=1
    [[ $pipe_error -eq 1 ]] || return 0
    [[ $dying -eq 0 ]] || return 0
    die "${BASH_SOURCE[0]} has been aborted with SIGPIPE (broken pipe)"
}

#----------------------------------------------------------------------------
function die() {
    local status=$?
    [[ $status -ne 0 ]] || status=255
    dying+=1

    printf "%s\n" "FATAL ERROR" "$@" >&2
    exit $status
}  

#############################################################################
function cleanup()
{
    printf "\nclean up\n"
    rm -rf /tmp/*
}


#############################################################################
function createUserAndGroup()
{
    local -r user=$1
    local -r uid=$2
    local -r group=$3
    local -r gid=$4
    local -r homedir=$5
    local -r shell=$6

    printf "\ncreate group:  %s\n" $group
    if [[ "$(cat /etc/group | grep -E ":${gid}:")" ]]; then
        [[  "$(cat /etc/group | grep -E "^${group}:x:${gid}:")"  ]] || exit 1
    fi
    [[ "$(cat /etc/group | grep -E "^${group}:")" ]] \
       ||  /usr/sbin/groupadd --gid "${gid}" "${group}"

    printf "create user: %s\n" $user
    if [[ "$(cat /etc/passwd | grep -E ":${uid}:")" ]]; then
        [[ "$(cat /etc/passwd | grep -E "^${user}:x:${uid}:${gid}:")" ]] || exit 1
    fi
    [[ "$(cat /etc/passwd | grep -E "^${user}:")" ]] \
       ||  /usr/sbin/useradd --home-dir "$homedir" --uid "${uid}" --gid "${gid}" --no-create-home --shell "${shell}" "${user}"
}

#############################################################################
function downloadFile()
{
    local -r name=$1
    local -r file="${name}_FILE"
    local -r url="${name}_URL"
    local -r sha="${name}_SHA256"

    printf "\nDownloading  %s\n" "${!file}"
    for i in {0..3}; do
        [[ i -eq 3 ]] && exit 1
        wget -O "${!file}" --no-check-certificate "${!url}"
        [[ $? -ne 0 ]] && continue
        local result=$(echo "${!sha}  ${!file}" | sha256sum -cw 2>&1)
        printf "%s\n" "$result"
        [[ $result != *' WARNING: '* ]] && return
        printf "Failed to successfully download ${!file}. Retrying....\n"
    done
}

#############################################################################
function downloadFiles()
{
    cd ${TOOLS}

    #downloadFile 'PHP' 
    downloadFile 'ZEN' 
}

#############################################################################
function fixupNginxLogDirecory()
{
    printf "\nfix default log directory for nginx\n"
    if [[ -h /var/lib/nginx ]]; then
        rm  /var/lib/nginx
    #    ln -s /var/log /var/lib/nginx
        mkdir -p /var/lib/nginx
    fi
}


#############################################################################
function installCUSTOMIZATIONS()
{
    printf "\nAdd configuration and customizations\n"
    cp -r "${TOOLS}/etc"/* /etc
#    cp -r "${TOOLS}/usr"/* /usr
#    cp -r "${TOOLS}/var"/* /var

    if [[ -h /var/lib/nginx/logs ]]; then
        rm /var/lib/nginx/logs
        ln -s /var/log /var/lib/nginx/logs
    fi
    [[ -d /var/nginx/client_body_temp ]] || mkdir -p /var/nginx/client_body_temp
    [[ -d /sessions ]]                   || mkdir -p /sessions
    [[ -d /var/run/php ]]                || mkdir -p /var/run/php
    [[ -d /run/nginx ]]                  || mkdir -p /run/nginx
}


#############################################################################
function installZENPHOTO()
{
    local -r file="$ZEN_FILE"

    printf "\nprepare and install %s\n" "${file}"
    cd ${TOOLS}
    tar xzf "${file}"
    cd "zenphoto-zenphoto-${ZEN_VERSION}"
    mkdir -p "${WWW}"
    mv -f * "${WWW}/"
}


#############################################################################
function installPHP()
{
    local -r file="$PHP_FILE"

    printf "\nprepare and install %s\n" "${file}"
    cd ${TOOLS}
    tar xf "${file}"

    cd "php-${PHP_VERSION}"
    ./configure --enable-fpm --with-mysql --enable-zip --disable-phar --with-libxml-dir=/usr/lib --enable-sockets
    make all
    make install
}


#############################################################################
function setPermissions()
{
    printf "\nmake sure that ownership & permissions are correct\n"

    chown root:root /etc/sudoers.d/*
    chmod 600 /etc/sudoers.d/*

    www_user='nobody'
    chown "${www_user}:${www_user}" -R /var/nginx/client_body_temp
    chown "${www_user}:${www_user}" -R /sessions
    chown "${www_user}:${www_user}" -R /var/run/php

    find "${WWW}" -type d -exec chmod 755 {} \;
    find "${WWW}" -type f -exec chmod 644 {} \;
    chown -R "${www_user}:${www_user}" "${WWW}"
}


#############################################################################

trap catch_error ERR
trap catch_int INT
trap catch_pipe PIPE 

set -o verbose

createUserAndGroup "${www_user}" "${www_uid}" "${www_group}" "${www_gid}" "${WWW}" /sbin/nologin

downloadFiles
fixupNginxLogDirecory
#installPHP
installZENPHOTO
installCUSTOMIZATIONS
setPermissions
cleanup
exit 0
