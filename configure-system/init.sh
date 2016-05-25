#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

source "${INSTALL_DIR}/variables.sh"
source "${INSTALL_DIR}/functions.sh"

_list=(clock symlinks misc network dhcpcd)

for i in ${_list[@]}; do
    case $i in
        * )
            pushd ${i}
                if [ -e DONE ]; then
                    echo success "${i} --> Already Built"
                else
                    echo empty
                    echo warn "Building ---> ${i}"
                    chrootSys "pushd /configure-system/${i} && bash build.sh |& tee build.log popd"

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