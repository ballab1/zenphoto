#!/bin/sh

die() {
    echo "$1"
    exit 1
}

osname() {
    if [ -e /etc/os-release ]; then
        cat /etc/os-release | grep -E '^ID=' 2>/dev/null | awk -F '=' '{print $2}' | tr -d '"'
    else
        die 'Unsupported OS - no /etc/os-release detected.'
    fi
}

echo '= Environment ======================================='
printf '    %s\n' $(env | sort)
echo '= Commandline Params ================================'
printf '    %s\n' "$@"
echo '= Variables used ===================================='
echo "    CBF_VERSION: .${CBF_VERSION}."
echo '====================================================='

case "$(osname)" in
    alpine)
        # ensure we have bash support
        if [ -z "$(type -P bash)" ]; then
            apk update
            apk add --no-cache bash ca-certificates openssl
        fi;;
    centos)
        # ensure we have wget support
        if [ -z "$(type -P wget)" ]; then
            yum update -y
            yum install -y wget openssl
        fi;;
    fedora)
        # ensure we have wget support
        if [ -z "$(type -P wget)" ]; then
            yum update -y
            yum install -y wget findutils
        fi;;
    ubuntu)
        # ensure we have wget support
        if [ "$(type wget)" = 'wget: not found' ]; then
            apt-get update
            apt-get install -y apt-utils wget ca-certificates openssl
        fi;;
    *)
        die "'$(osname)' is not supported at this time";;
esac

cd /tmp
cbf_dir=/tmp/container_build_framework

# check if we need to download CBF
if [ -d "$cbf_dir" ]; then
    echo "Using local build version of CBF"
    find /tmp -name 'C?F.properties' -delete

elif [ "$CBF_VERSION" ]; then
    # since no CBF directory located, attempt to download CBF based on specified verion
    CBF_TGZ=/tmp/cbf.tar.gz
    CBF_URL="https://github.com/ballab1/container_build_framework/archive/${CBF_VERSION}.tar.gz"
    echo "Downloading CBF:$CBF_VERSION from $CBF_URL"

    if [ "$(type wget)" ]; then
        wget --no-check-certificate --quiet --output-document="$CBF_TGZ" "$CBF_URL" || die "Failed to download $CBF_URL"

    elif [ "$(type curl)" ]; then
        curl --insecure --silent --output "$CBF_TGZ" "$CBF_URL" || die "Failed to download $CBF_URL"

    else
        die "Neither wget or curl is installed to download cbf from $CBF_URL"
    fi

    echo 'Unpacking downloaded copy of CBF'
    tar --exclude 'C?F.properties' -xzf "$CBF_TGZ" || die "Failed to unpack $CBF_TGZ"
    cbf_dir="$( ls -d container_build_framework* 2>/dev/null )"

else
    echo 'Unpacking stashed copy of CBF'

    # setup pointer to archive from prior build
    CBF_TGZ=/usr/local/crf/cbf.tar.gz
    mkdir -p "$cbf_dir" || die 'Unable to unpack stashed CBF'
    tar --exclude 'C?F.properties'  -xzf "$CBF_TGZ" -C "$cbf_dir" || die "Failed to unpack $CBF_TGZ"
fi


# verify CBF directory exists
[ "$cbf_dir" ] && [ -d "$cbf_dir" ] ||  die 'No framework directory located'


echo "loading framework from ${cbf_dir}"
chmod 755 "${cbf_dir}/cbf/bin/build.sh"
exec "${cbf_dir}/cbf/bin/build.sh" "$@"