#!/bin/sh

# ensure we have bash support
if [ -z "$(which bash)" ]; then
    apk update
    apk add --no-cache bash ca-certificates openssl 
fi

cd /tmp
cbf_dir=/tmp/container_build_framework

if [ ! -d "$cbf_dir" ] && [ "${CBF_VERSION}" ]; then
    # since no CBF directory located, attempt to download CBF based on specified verion
    CBF_URL="https://github.com/ballab1/container_build_framework/archive/${CBF_VERSION}.tar.gz"
    wget --no-check-certificate --quiet --output-document=- "$CBF_URL" | tar -xz
    [ $? -eq 0 ] || exit 1
    cbf_dir="$( ls -d container_build_framework-* 2>/dev/null )"
fi

CBF_TGZ=/usr/local/crf/cbf.tar.gz
if [ ! -d "$cbf_dir" ] && [ -e "$CBF_TGZ" ]; then
    cbf_dir=/tmp/container_build_framework
    mkdir -p "$cbf_dir"
    tar -xzf "$CBF_TGZ" -C "$cbf_dir"
fi

if [ -z "$cbf_dir" ] || [ ! -d "$cbf_dir" ]; then
    echo 'No framework directory located'
    exit 1
fi

echo "loading framework from ${cbf_dir}"
chmod 755 "${cbf_dir}/bin/build.sh"
exec "${cbf_dir}/bin/build.sh" "$@"