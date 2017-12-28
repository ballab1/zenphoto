#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose

        
declare -r CONTAINER='ZENPHOTO'

declare -r TZ="${TZ:-'America/New_York'}"
declare -r SESSIONS_DIR='/sessions'
declare -r TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  


declare -r BUILDTIME_PKGS="alpine-sdk php5-dev pcre-dev build-base autoconf libtool bash-completion busybox file git gnutls-utils libxml2-dev linux-headers musl-utils"
declare -r CORE_PKGS="bash curl findutils libgd libxml2 mysql-client nginx openssh-client shadow sudo supervisor ttf-dejavu tzdata unzip util-linux zlib"
declare -r PHP_PKGS="php5-fpm php5-ctype php5-common php5-dom php5-gettext php5-iconv php5-gd php5-json php5-mysql php5-posix php5-sockets php5-xml php5-xmlreader php5-xmlrpc php5-xsl php5-zip"
declare -r ZEN_PKGS="freetype gd jpeg libjpeg libpng openssl rsync" 

    
# zenphoto
declare -r ZEN_VERSION=${ZEN_VERSION:-'1.4.14'}
declare -r ZEN_FILE="zenphoto-${ZEN_VERSION}.tar.gz"
declare -r ZEN_URL="https://github.com/zenphoto/zenphoto/archive/zenphoto-${ZEN_VERSION}.tar.gz"
declare -r ZEN_SHA256="ecd0efac214e60be9ed339977d7be946a34f6eeb5fe2adc6c20fa42bd450ebff"


#directories
declare -r WWW=/var/www
declare -r ZEN_DIR="${WWW}/photos"

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

    apk del .buildDepedencies
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
    local result
    
    local wanted=$( printf '%s:%s' $group $gid )
    local nameMatch=$( getent group "${group}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    local idMatch=$( getent group "${gid}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    printf "\e[1;34mINFO: group/gid (%s):  is currently (%s)/(%s)\e[0m\n" "$wanted" "$nameMatch" "$idMatch"           

    if [[ $wanted != $nameMatch  ||  $wanted != $idMatch ]]; then
        printf "\ncreate group:  %s\n" $group
        [[ "$nameMatch"  &&  $wanted != $nameMatch ]] && groupdel "$( getent group ${group} | awk -F ':' '{ print $1 }' )"
        [[ "$idMatch"    &&  $wanted != $idMatch ]]   && groupdel "$( getent group ${gid} | awk -F ':' '{ print $1 }' )"
        /usr/sbin/groupadd --gid "${gid}" "${group}"
    fi

    
    wanted=$( printf '%s:%s' $user $uid )
    nameMatch=$( getent passwd "${user}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    idMatch=$( getent passwd "${uid}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    printf "\e[1;34mINFO: user/uid (%s):  is currently (%s)/(%s)\e[0m\n" "$wanted" "$nameMatch" "$idMatch"    
    
    if [[ $wanted != $nameMatch  ||  $wanted != $idMatch ]]; then
        printf "create user: %s\n" $user
        [[ "$nameMatch"  &&  $wanted != $nameMatch ]] && userdel "$( getent passwd ${user} | awk -F ':' '{ print $1 }' )"
        [[ "$idMatch"    &&  $wanted != $idMatch ]]   && userdel "$( getent passwd ${uid} | awk -F ':' '{ print $1 }' )"

        /usr/sbin/useradd --home-dir "$homedir" --uid "${uid}" --gid "${gid}" --no-create-home --shell "${shell}" "${user}"
    fi
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
function header()
{
    local -r bars='+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
    printf "\n\n\e[1;34m%s\nBuilding container: \e[0m%s\e[1;34m\n%s\e[0m\n" $bars $CONTAINER $bars
}
 
#############################################################################
function install_CUSTOMIZATIONS()
{
    printf "\nAdd configuration and customizations\n"
    cp -r "${TOOLS}/etc"/* /etc
    cp -r "${TOOLS}/usr"/* /usr
    cp -r "${TOOLS}/var"/* /var

    ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

    [[ -f /etc/conf.d/nginx/default.conf ]]  && rm /etc/nginx/conf.d/default.conf
    if [[ -h /var/lib/nginx/logs ]]; then
        rm /var/lib/nginx/logs
        ln -s /var/log /var/lib/nginx/logs
    fi
    [[ -d /var/nginx/client_body_temp ]]     || mkdir -p /var/nginx/client_body_temp
    [[ -d "${SESSIONS_DIR}" ]]               || mkdir -p "${SESSIONS_DIR}"
    [[ -d /var/run/php ]]                    || mkdir -p /var/run/php
    [[ -d /run/nginx ]]                      || mkdir -p /run/nginx
    
    sed -i "s|^.*date.timezone =.*$|date.timezone = ${TZ}|" '/etc/php5/php.ini'
    sed -i "s|^.*session.save_path =.*$|session.save_path = \"${SESSIONS_DIR}\"|" '/etc/php5/php.ini'
}

#############################################################################
function installAlpinePackages()
{
    apk update
    apk add --no-cache --virtual .buildDepedencies $BUILDTIME_PKGS 
    apk add --no-cache $CORE_PKGS $PHP_PKGS $ZEN_PKGS
}

#############################################################################
function install_ZENPHOTO()
{
    local -r file="$ZEN_FILE"

    printf "\nprepare and install %s\n" "${file}"
    cd ${TOOLS}
    tar xzf "${file}"
    cd "zenphoto-zenphoto-${ZEN_VERSION}"
    mkdir -p "${WWW}/photos"
    mv -f * "${WWW}/photos"
}

#############################################################################
function installAlpinePackages()
{
    apk update
    apk add --no-cache --virtual .buildDepedencies $BUILDTIME_PKGS 
    apk add --no-cache $CORE_PKGS
    apk add --no-cache $PHP_PKGS
    apk add --no-cache $ZEN_PKGS
}

#############################################################################
function installTimezone() {
    echo "$TZ" > /etc/TZ
    cp /usr/share/zoneinfo/$TZ /etc/timezone
    cp /usr/share/zoneinfo/$TZ /etc/localtime
}

#############################################################################
function setPermissions()
{
    printf "\nmake sure that ownership & permissions are correct\n"

    chown root:root /etc/sudoers.d/*
    chmod 600 /etc/sudoers.d/*

    chmod u+rwx /usr/local/bin/docker-entrypoint.sh

    find "${WWW}" -type d -exec chmod 755 {} \;
    find "${WWW}" -type f -exec chmod 444 {} \;
    
    cd "${ZEN_DIR}/zp-data"
    chmod 444 .htaccess
    chmod 600 security.log
    chmod 600 zenphoto.cfg.*
    

www_user='nobody'
www_group='nobody'
    chown "${www_user}:${www_group}" -R /var/nginx/client_body_temp
    chown "${www_user}:${www_group}" -R /sessions
    chown "${www_user}:${www_group}" -R /var/run/php
    chown "${www_user}:${www_group}" -R /var/log
    chown "${www_user}:${www_group}" -R "${WWW}"
}

#############################################################################

trap catch_error ERR
trap catch_int INT
trap catch_pipe PIPE 

set -o verbose

header
export DBUSER="${DBUSER?'Envorinment variable DBUSER must be defined'}"
export DBPASS="${DBPASS?'Envorinment variable DBPASS must be defined'}"
export DBHOST="${DBHOST:-'mysql'}" 

installAlpinePackages
installTimezone
createUserAndGroup "${www_user}" "${www_uid}" "${www_group}" "${www_gid}" "${WWW}" /sbin/nologin
downloadFiles
fixupNginxLogDirecory
install_ZENPHOTO
install_CUSTOMIZATIONS
setPermissions
cleanup
exit 0
