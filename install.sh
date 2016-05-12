#!/usr/bin/env bash

# This script generates a 64-bit system
source variables.sh
source functions.sh

# Remove all the old files/folders
echo warn "Removing old files/folders"
requireRoot rm -rfv /tools
requireRoot rm -rfv /cross-tools
requireRoot rm -rfv "${PWD}/.config"
echo success "Finished..."
echo empty


# Create new configuration file
cat > "${PWD}/.config" << "EOF"
#!/usr/bin/env bash
EOF

# Update installation configuration information
echo norm "export INSTALL_DIR=${INSTALL_DIR}"                                        >> "${PWD}/.config"
echo norm "export MAKE_TESTS=TRUE"                                                   >> "${PWD}/.config"
echo norm "export MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)""   >> "${PWD}/.config"
echo norm "export TARGET=$TARGET" 		                                            >> "${PWD}/.config"
echo norm "export PATH=$TMP_PATH"		                                            >> "${PWD}/.config"
echo norm "export HOST=$HOST"     		                                            >> "${PWD}/.config"
echo norm "export BUILD64=$BUILD64"  	                                            >> "${PWD}/.config"
echo norm "export LC_ALL=$LC_ALL" 		                                            >> "${PWD}/.config"
echo norm "export VM_LINUZ=$VM_LINUZ" 		                                        >> "${PWD}/.config"
echo norm "export SYSTEM_MAP=$SYSTEM_MAP"                                        	>> "${PWD}/.config"
echo norm "export CONFIG_BACKUP=$CONFIG_BACKUP"                                      >> "${PWD}/.config"

# Make all the configurations available
source "${PWD}/.config"

# Create necessary directories and symlinks
echo warn "Creating necessary folders. Please wait..."
requireRoot install -dv "${TOOLS_DIR}"
requireRoot ln -sv "${TOOLS_DIR}" /
requireRoot install -dv "${CROSS_TOOLS_DIR}"
requireRoot ln -sv "${CROSS_TOOLS_DIR}" /
echo success "Finished..."
echo empty

# Change folder permissions to `whoami`
requireRoot chown -R `whoami` "${INSTALL_DIR}"

# Copy the data to the installation directory
echo empty
echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
cp -ur ./* "${INSTALL_DIR}"
cp -ur "${PWD}/.config" "${INSTALL_DIR}"
echo success "Finished copying..."
echo empty

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N
#----------------------------------------------------------------------------------------------------#

# Construct cross-compile tools
cd "${CROSS_COMPILE_TOOLS_DIR}" && bash init.sh