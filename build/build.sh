#!/bin/bash

cd /tmp
declare cbf_dir=/tmp/container_build_framework

if [ ! -d "$cbf_dir" ]; then

    declare cbf_tar=$( ls *.tar.gz )
    [ -z "$cbf_tar" ] || tar xzf "${cbf_tar}"

    cbf_dir="$( ls -d container_build_framework-* )"
    [ "$cbf_dir" ] || exit 1
fi

source "${cbf_dir}/bin/build.sh" "$@"