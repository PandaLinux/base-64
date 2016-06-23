#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

source ${HOME}/variables.sh
source ${HOME}/functions.sh

verify-user;

# Create log directory
install -d ${LOGS_DIR}/configure-system
# Create DONE directory
install -d ${DONE_DIR}/configure-system

if [ -f ${DONE_DIR}/build-system/clean ]; then
    _list=(clock symlinks misc network dhcpcd)

    for i in ${_list[@]}; do
        case $i in
            * )
                pushd ${i}
                    if [ -f ${DONE_DIR}/configure-system/${i} ]; then
                        echo success "${i} --> Already Built"
                    else
                        echo empty
                        echo warn "Building ---> ${i}"
                        chrootSys "source /.vars && pushd /configure-system/${i} && bash build.sh |& tee ${LOGS_DIR_CONFIGURE_SYSTEM} && popd"

                        if [ -f ${DONE_DIR}/configure-system/${i} ]; then
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
fi