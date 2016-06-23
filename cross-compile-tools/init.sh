#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

source ${HOME}/variables.sh
source ${HOME}/functions.sh

verify-user;

# Create log directory
LOGS_DIR_CROSS_COMPILE_TOOLS=${LOGS_DIR}/cross-compile-tools
install -d ${LOGS_DIR_CROSS_COMPILE_TOOLS}
# Create DONE directory
DONE_DIR_CROSS_COMPILE_TOOLS=${DONE_DIR}/cross-compile-tools
install -d ${DONE_DIR_CROSS_COMPILE_TOOLS}

export DONE_DIR_CROSS_COMPILE_TOOLS

_list=(file linux-headers m4 ncurses pkg-config-lite gmp mpfr mpc isl cloog binutils gcc-static glibc gcc-final)

for i in ${_list[@]}; do
    case $i in
        * )
            pushd ${i}
                if [ -f ${DONE_DIR_CROSS_COMPILE_TOOLS}/${i} ]; then
                    echo success "${i} --> Already Built"
                else
                    echo empty
                    echo warn "Building ---> ${i}"
                    bash build.sh |& tee ${LOGS_DIR_CROSS_COMPILE_TOOLS}/${i}.log

                    if [ -f ${DONE_DIR_CROSS_COMPILE_TOOLS}/${i} ]; then
                        echo success "Building ---> ${i} completed"
                    else
                        echo error "Building ---> ${i} failed"
                        echo error "See ${LOGS_DIR_CROSS_COMPILE_TOOLS}/${i}.log for more details..."
                        exit 1
                    fi

                    echo empty
                fi
            popd;;
    esac
done