#!/bin/sh

function die() {
    echo "$1"
    exit 1
}

echo '= Environment ======================================='
printf "    %s\n" $(env | sort)
echo '= Commandline Params ================================'
printf "    %s\n" "$@"
echo '= Variables used ===================================='
echo "    CBF_VERSION: .${CBF_VERSION}."
echo '=====================================================' 

if [ -e /etc/os-release ] && [ "$(grep -c 'ID=alpine' /etc/os-release 2>/dev/null)" -ne 0 ]; then
    # ensure we have bash support (on Alpine)
    if  [ -z "$(which bash)" ]; then
        apk update
        apk add --no-cache bash ca-certificates openssl 
    fi
fi

cd /tmp
cbf_dir=/tmp/container_build_framework

if [ ! -d "$cbf_dir" ] && [ "$CBF_VERSION" ]; then
    echo "Downloading CBF:$CBF_VERSION from github"
    # since no CBF directory located, attempt to download CBF based on specified verion
    CBF_URL="https://github.com/ballab1/container_build_framework/archive/${CBF_VERSION}.tar.gz"
    (wget --no-check-certificate --quiet --output-document=- "$CBF_URL" | tar -xz) || die 'Failed to download CBF'
    cbf_dir="$( ls -d container_build_framework-* 2>/dev/null )"
fi

CBF_TGZ=/usr/local/crf/cbf.tar.gz
if [ ! -d "$cbf_dir" ] && [ -e "$CBF_TGZ" ]; then
    echo 'Unpacking stashed copy of CBF'
    cbf_dir=/tmp/container_build_framework
    mkdir -p "$cbf_dir" || die 'Unable to unpack stashed CBF'
    tar -xzf "$CBF_TGZ" -C "$cbf_dir"
fi

[ "$cbf_dir" ] && [ -d "$cbf_dir" ]  ||  die 'No framework directory located'


echo "loading framework from ${cbf_dir}"
chmod 755 "${cbf_dir}/cbf/bin/build.sh"
exec "${cbf_dir}/cbf/bin/build.sh" "$@"