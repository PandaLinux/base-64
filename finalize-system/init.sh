#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

source ${HOME}/variables.sh
source ${HOME}/functions.sh

verify-user;

echo warn "Finalize the system..."

# Create log directory
install -d ${LOGS_DIR}/finalize-system
# Create DONE directory
install -d ${DONE_DIR}/finalize-system

if [ -f ${DONE_DIR}/configure-system/dhcpcd ]; then
    _list=(bash-startup-files bash-completion configure-user dpkg sudo busybox cpio linux-kernel lsb initramfs)

    for i in ${_list[@]}; do
        case $i in
            * )
                if [ -f ${DONE_DIR}/finalize-system/${i} ]; then
                    echo success "${i} --> Already Built"
				else
                    echo empty
                    echo warn "Building ---> ${i}"
                    chrootSys "source /.vars && pushd /$(basename $(pwd))/${i} && bash build.sh |& tee ${LOGS_DIR_FINALIZE_SYSTEM} popd"

                    if [ -f ${DONE_DIR}/finalize-system/${i} ]; then
                        echo success "Building ---> ${i} completed"
                    else
                        echo error "Building ---> ${i} failed"
                        exit 1
					fi

                    echo empty
				fi;;
        esac
    done
fi

echo empty