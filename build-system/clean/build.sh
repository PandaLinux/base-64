#!/usr/bin/env bash

shopt -s -o pipefail

function clean() {
    rm -rfv /tmp/*

    ${HOST_TOOLS_DIR}/bin/find /{,usr/}{bin,lib,sbin} -type f \
        -exec ${HOST_TOOLS_DIR}/bin/strip --strip-debug '{}' ';'
}

# Run the installation procedure
time { touch DONE;clean; }