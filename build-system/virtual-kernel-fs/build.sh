#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: Various file systems exported by the kernel are used to communicate to and from the kernel"
    echo -e "itself. These file systems are virtual in that no disk space is used for them. The content of the file systems"
    echo -e "resides in memory."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function build() {
    mkdir -pv ${INSTALL_DIR}/{dev,proc,run,sys}
}

# Run the installation procedure
time { help;build; }
# Verify installation
if [ -d "${INSTALL_DIR}/dev" ]; then
    touch DONE
fi