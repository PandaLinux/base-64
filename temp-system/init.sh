#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

source ${HOME}/variables.sh
source ${HOME}/functions.sh

verify-user;

echo warn "Constructing temporary system..."

# Create log directory
LOGS_DIR_TEMP_SYSTEM=${LOGS_DIR}/temp-system
install -d ${LOGS_DIR_TEMP_SYSTEM}
# Create DONE directory
DONE_DIR_TEMP_SYSTEM=${DONE_DIR}/temp-system
install -d ${DONE_DIR_TEMP_SYSTEM}

export DONE_DIR_TEMP_SYSTEM

_list=(binutils_pass1 gcc_pass1 linux_headers)

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
echo empty
