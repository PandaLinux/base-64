#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

source "${INSTALL_DIR}/variables.sh"
source "${INSTALL_DIR}/functions.sh"
source "${CONFIG_FILE}"

if [ -f "${CROSS_COMPILE_TOOLS_DIR}/gcc-final/DONE" ]; then
    _list=(build-variables gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils diffutils file \
            findutils gawk gettext grep)

    for i in ${_list[@]}; do
        case $i in
            * )
                pushd ${i}
                    if [ -e DONE ]; then
                        echo success "${i} --> Already Built"
                    else
                        echo empty
                        echo warn "Building ---> ${i}"
                        bash build.sh |& tee build.log

                        if [ -e DONE ]; then
                            echo success "Building ---> ${i} completed"
                        else
                            echo error "Building ---> ${i} failed"
                            exit 1
                        fi

                        echo empty
                    fi
                popd;;
        esac
    done
else
    echo error "Installation failed..."
    exit 1
fi
