#!/bin/bash

cd /tmp
declare cbf_dir=/tmp/container_build_framework

if [ ! -d "$cbf_dir" ]; then
    # since no CBF directory located, attempt to download CBF based on specified verion
    declare CBF_URL="https://github.com/ballab1/container_build_framework/archive/${CBF_VERSION}.tar.gz"         
    wget --no-check-certificate --quiet --output-document=- "$CBF_URL" | tar -xz
    cbf_dir="$( ls -d container_build_framework-* )"
fi
if [ -z "$cbf_dir" ] || [ ! -d "$cbf_dir" ]; then
    echo 'No framework directory located'
    exit 1
fi

echo "loading framework from ${cbf_dir}"
chmod 755 "${cbf_dir}/bin/build.sh"
exec "${cbf_dir}/bin/build.sh" "$@"