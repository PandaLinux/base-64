#!/usr/bin/env bash

# This script generates a 64-bit system
source variables.sh
source functions.sh

# Remove all the old files/folders
echo warn "Removing old folders"
requireRoot rm -rf "${HOST_TOOLS_DIR}"
requireRoot rm -rf "${HOST_CROSS_TOOLS_DIR}"
echo success "Finished..."
echo empty

# Create installation folder
requireRoot mkdir -p "${INSTALL_DIR}"

# Create necessary directories and symlinks
echo warn "Creating necessary folders. Please wait..."
requireRoot install -d "${TOOLS_DIR}"
requireRoot ln -s "${TOOLS_DIR}" /
requireRoot install -d "${CROSS_TOOLS_DIR}"
requireRoot ln -s "${CROSS_TOOLS_DIR}" /

# Change folder permissions to `whoami`
requireRoot chown -R `whoami` "${INSTALL_DIR}"
requireRoot chown -R `whoami` "${HOST_TOOLS_DIR}"
requireRoot chown -R `whoami` "${HOST_CROSS_TOOLS_DIR}"

echo success "Finished..."
echo empty

# Create new configuration file
cat > "${INSTALL_DIR}/.config" << "EOF"
#!/usr/bin/env bash
EOF

# Update installation configuration information
echo norm "export INSTALL_DIR=${INSTALL_DIR}"                                       >> "${INSTALL_DIR}/.config"
echo norm "export HOST_TOOLS_DIR=${HOST_TOOLS_DIR}"                                 >> "${INSTALL_DIR}/.config"
echo norm "export HOST_CROSS_TOOLS_DIR=${HOST_CROSS_TOOLS_DIR}"                     >> "${INSTALL_DIR}/.config"
echo norm "export MAKE_TESTS=TRUE"                                                  >> "${INSTALL_DIR}/.config"
echo norm "export MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)""  >> "${INSTALL_DIR}/.config"
echo norm "export TARGET=$TARGET" 		                                            >> "${INSTALL_DIR}/.config"
echo norm "export PATH=$TMP_PATH"		                                            >> "${INSTALL_DIR}/.config"
echo norm "export HOST=$HOST"     		                                            >> "${INSTALL_DIR}/.config"
echo norm "export BUILD64=$BUILD64"  	                                            >> "${INSTALL_DIR}/.config"
echo norm "export LC_ALL=$LC_ALL" 		                                            >> "${INSTALL_DIR}/.config"
echo norm "export VM_LINUZ=$VM_LINUZ" 		                                        >> "${INSTALL_DIR}/.config"
echo norm "export SYSTEM_MAP=$SYSTEM_MAP"                                        	>> "${INSTALL_DIR}/.config"
echo norm "export CONFIG_BACKUP=$CONFIG_BACKUP"                                     >> "${INSTALL_DIR}/.config"

# Make all the configurations available
source "${INSTALL_DIR}/.config"

# Copy the data to the installation directory
echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
cp -ur ./* "${INSTALL_DIR}"
echo empty

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N
#----------------------------------------------------------------------------------------------------#

# Construct cross-compile tools
cd "${CROSS_COMPILE_TOOLS_DIR}" && bash init.sh