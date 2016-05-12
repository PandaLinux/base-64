#!/usr/bin/env bash

# This script generates a 64-bit system
source variables.sh
source functions.sh

# Remove all the old files/folders
echos warn "Removing old files/folders"
requireRoot rm -rfv /tools
requireRoot rm -rfv /cross-tools
requireRoot rm -rfv "${PWD}/.config"
echos success "Finished..."
echos empty


# Create new configuration file
cat > "${PWD}/.config" << "EOF"
#!/usr/bin/env bash
EOF

# Update installation configuration information
echo "export INSTALL_DIR=${INSTALL_DIR}"                                        >> "${PWD}/.config"
echo "export MAKE_TESTS=TRUE"                                                   >> "${PWD}/.config"
echo "export MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)""   >> "${PWD}/.config"
echo "export TARGET=$TARGET" 		                                            >> "${PWD}/.config"
echo "export PATH=$TMP_PATH"		                                            >> "${PWD}/.config"
echo "export HOST=$HOST"     		                                            >> "${PWD}/.config"
echo "export BUILD64=$BUILD64"  	                                            >> "${PWD}/.config"
echo "export LC_ALL=$LC_ALL" 		                                            >> "${PWD}/.config"
echo "export VM_LINUZ=$VM_LINUZ" 		                                        >> "${PWD}/.config"
echo "export SYSTEM_MAP=$SYSTEM_MAP"                                        	>> "${PWD}/.config"
echo "export CONFIG_BACKUP=$CONFIG_BACKUP"                                      >> "${PWD}/.config"

# Make all the configurations available
source "${PWD}/.config"

# Create necessary directories and symlinks
echos warn "Creating necessary folders. Please wait..."
requireRoot install -dv "${TOOLS_DIR}"
requireRoot ln -sv "${TOOLS_DIR}" /
requireRoot install -dv "${CROSS_TOOLS_DIR}"
requireRoot ln -sv "${CROSS_TOOLS_DIR}" /
echos success "Finished..."
echos empty

# Copy the data to the installation directory
echos empty
echos warn "Copying data to ${INSTALL_DIR}. Please wait..."
cp -ur ./* "${INSTALL_DIR}"
cp -ur "${PWD}/.config" "${INSTALL_DIR}"
echos success "Finished copying..."
echos empty

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N
#----------------------------------------------------------------------------------------------------#

# Construct cross-compile tools
cd "${CROSS_COMPILE_TOOLS_DIR}" && bash init.sh