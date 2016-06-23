#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

source ${HOME}/variables.sh
source ${HOME}/functions.sh

verify-user;

# Create log directory
LOGS_DIR_TEMP_SYSTEM=${LOGS_DIR}/temp-system
install -d ${LOGS_DIR_TEMP_SYSTEM}
# Create DONE directory
DONE_DIR_TEMP_SYSTEM=${DONE_DIR}/temp-system
install -d ${DONE_DIR_TEMP_SYSTEM}

export DONE_DIR_TEMP_SYSTEM

if [ -f "${DONE_DIR}/cross-compile-tools/gcc-final" ]; then
    _list=(build-variables gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils diffutils file \
           findutils gawk gettext grep gzip make patch sed tar texinfo util-linux vim xz-utils)

    for i in ${_list[@]}; do
        case $i in
            * )
                pushd ${i}
                    if [ -f ${DONE_DIR_TEMP_SYSTEM}/${i} ]; then
                        echo success "${i} --> Already Built"
                    else
                        echo empty
                        echo warn "Building ---> ${i}"
                        bash build.sh |& tee ${LOGS_DIR_TEMP_SYSTEM}/${i}.log

                        if [ -f ${DONE_DIR_TEMP_SYSTEM}/${i} ]; then
                            echo success "Building ---> ${i} completed"
                        else
                            echo error "Building ---> ${i} failed"
                            echo error "See ${LOGS_DIR_TEMP_SYSTEM}/${i}.log for more details..."
                            exit 1
                        fi

                        echo empty
                    fi
                popd;;
        esac
    done
fi