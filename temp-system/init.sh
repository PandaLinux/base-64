#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

source "$SRC"/variables.sh
source "$SRC"/functions.sh

echo warn "Constructing temporary system..."

_list=(binutils_pass1 gcc_pass1 linux_headers glibc libstdc++ binutils_pass2)

    for i in "${_list[@]}"; do
        case $i in
            * )
                pushd "${i}"
                    echo empty
                    echo warn "Building ---> ${i}"
                    bash build.sh
                popd;;
        esac
    done
echo empty
