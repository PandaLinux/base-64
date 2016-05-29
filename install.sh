#!/usr/bin/env bash

set -e # Exit upon error

# This script generates a 64-bit system
source variables.sh
source functions.sh

# Show installation configuration information to the user
echo warn "General Installation Configuration"
echo norm "${BOLD}Installation Directory:${NORM}    ${INSTALL_DIR}"
echo norm "${BOLD}Run tests:${NORM}                 ${MAKE_TESTS}"
echo norm "${BOLD}Speed:${NORM}                     $(cat /proc/cpuinfo | grep processor | wc -l)x"
echo norm "${BOLD}Building for:${NORM}              ${TARGET}"
echo empty

# Remove all the old files/folders
echo warn "Removing old folders"
[ -f backup.tar.bz2 ] && requireRoot rm -rf "${INSTALL_DIR}"
requireRoot rm -rf "${HOST_TOOLS_DIR}"
requireRoot rm -rf "${HOST_CROSS_TOOLS_DIR}"
echo empty

if [ ! -d "${INSTALL_DIR}" ]; then
    # Create installation folder
    echo warn "Create root folder..."
    requireRoot mkdir -p "${INSTALL_DIR}"
    requireRoot chown -R `whoami` "${INSTALL_DIR}"
    echo empty
fi

# If backup exists, untar and copy it to the ${INSTALL_DIR}
#if [ -f "backup.tar.bz2" ]; then
#    echo warn "Unpacking and moving backup to ${INSTALL_DIR}..."
#    requireRoot tar -pxPf backup.tar.bz2 &&
#    requireRoot rm -r backup.tar.bz2
#    echo success "Finished moving backup..."
#    echo empty
#fi

if [ ! -d "${INSTALL_DIR}/dev" ]; then
    # Create necessary directories and symlinks
    echo warn "Creating necessary folders. Please wait..."
    requireRoot install -d "${TOOLS_DIR}"
    requireRoot install -d "${CROSS_TOOLS_DIR}"

    echo empty
    echo warn "Creating symlinks..."
    requireRoot ln -s "${TOOLS_DIR}" /
    requireRoot ln -s "${CROSS_TOOLS_DIR}" /

    # Change folder permissions to `whoami`
    requireRoot chown -R `whoami` "${INSTALL_DIR}"
    requireRoot chown -R `whoami` "${HOST_TOOLS_DIR}"
    requireRoot chown -R `whoami` "${HOST_CROSS_TOOLS_DIR}"

else
    echo warn "Creating symlinks..."
    requireRoot ln -s "${TOOLS_DIR}" /
    requireRoot ln -s "${CROSS_TOOLS_DIR}" /

    # Change folder permissions to `0:0`
    requireRoot chown -R 0:0 "${HOST_TOOLS_DIR}"
    requireRoot chown -R 0:0 "${HOST_CROSS_TOOLS_DIR}"
fi

# Copy the data to the installation directory
echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
cp -ur ./* "${INSTALL_DIR}"
echo empty

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N
#----------------------------------------------------------------------------------------------------#

echo success "Starting installation..."
echo empty

# Construct cross-compile tools
pushd "${CROSS_COMPILE_TOOLS_DIR}" && bash init.sh && popd
# Build temporary system
pushd "${TEMP_SYSTEM_DIR}" && bash init.sh && popd
# Build the system
#pushd "${BUILD_SYSTEM_DIR}" && bash init.sh && popd
# Configure the system
#pushd "${CONFIGURE_SYSTEM_DIR}" && bash init.sh && popd
# Finalize the system
#pushd "${FINALIZE_SYSTEM_DIR}" && bash init.sh && popd

#echo empty
#echo warn "Creating backup..."
# Backup the system
#requireRoot tar -jcpPf "${DIR}/backup.tar.bz2" "${INSTALL_DIR}"
#requireRoot chown `whoami` "${DIR}/backup.tar.bz2"
#echo success "Backup created at ${DIR}/backup.tar.bz2"
#echo empty

#exit 1