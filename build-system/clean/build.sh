#!/usr/bin/env bash

shopt -s -o pipefail
set -e

function clean() {
    rm -rfv /tmp/*

    ${HOST_TDIR}/bin/find /{,usr/}{bin,lib,sbin} -type f \
        -exec ${HOST_TDIR}/bin/strip --strip-debug '{}' ';'
}

# Run the installation procedure
time { touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd));clean; }