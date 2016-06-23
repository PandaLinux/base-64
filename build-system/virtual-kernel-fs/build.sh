#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

function showHelp() {
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

function saveVariables() {
    [ -f ${INSTALL_DIR}/.vars ] && rm -v ${INSTALL_DIR}/.vars

    # Prepare new environment variables
    touch ${INSTALL_DIR}/.vars

    # Add variables
    echo "export HOST_TDIR=${HOST_TDIR}"            >> ${INSTALL_DIR}/.vars
    echo "export HOST_CDIR=${HOST_CDIR}"            >> ${INSTALL_DIR}/.vars
    echo "export BUILD64=-m64"                      >> ${INSTALL_DIR}/.vars
    echo "export MAKE_TESTS=${MAKE_TESTS}"          >> ${INSTALL_DIR}/.vars
    echo "export MAKE_PARALLEL=${MAKE_PARALLEL}"    >> ${INSTALL_DIR}/.vars
    echo "export LC_ALL=${LC_ALL}"                  >> ${INSTALL_DIR}/.vars
    echo "export VM_LINUZ=${VM_LINUZ}"              >> ${INSTALL_DIR}/.vars
    echo "export SYSTEM_MAP=${SYSTEM_MAP}"          >> ${INSTALL_DIR}/.vars

    # TODO: Fix hardcoded path
    echo "export DONE_DIR_BUILD_SYSTEM=/done/build-system"          >> ${INSTALL_DIR}/.vars
    echo "export DONE_DIR_CONFIGURE_SYSTEM=/done/configure-system"  >> ${INSTALL_DIR}/.vars
    echo "export DONE_DIR_FINALIZE_SYSTEM=/done/finalize-system"    >> ${INSTALL_DIR}/.vars

    echo "export LOGS_DIR_BUILD_SYSTEM=/logs/build-system"          >> ${INSTALL_DIR}/.vars
    echo "export LOGS_DIR_CONFIGURE_SYSTEM=/logs/configure-system"  >> ${INSTALL_DIR}/.vars
    echo "export LOGS_DIR_FINALIZE_SYSTEM=/logs/finalize-system"    >> ${INSTALL_DIR}/.vars
}

# Run the installation procedure
time { showHelp;build;saveVariables; }
# Verify installation
if [ -d ${INSTALL_DIR}/dev ] && [ -f ${INSTALL_DIR}/.vars ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi