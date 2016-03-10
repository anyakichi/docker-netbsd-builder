#!/bin/bash

set -o nounset
set -o pipefail

: ${BUILD_USER:=builder}
: ${BUILD_GROUP:=builder}

uid=$(stat -c "%u" .)
gid=$(stat -c "%g" .)

if [ $uid -ne 0 ]; then
    if [ $(id -g ${BUILD_GROUP}) -ne ${gid} ]; then
        getent group ${gid} >/dev/null 2>&1 || groupmod -g ${gid} ${BUILD_GROUP}
        chgrp -R ${gid} /home/${BUILD_USER}
    fi
    if [ $(id -u ${BUILD_USER}) -ne ${uid} ]; then
        usermod -u ${uid} ${BUILD_USER}
    fi
fi

if [ $# -ne 0 ]; then
    if buildenv "$1" -h >/dev/null 2>&1; then
        exec sudo -EHsu ${BUILD_USER} buildenv "$@"
    else
        exec sudo -EHsu ${BUILD_USER} "$@"
    fi
fi
