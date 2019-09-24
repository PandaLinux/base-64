#!/usr/bin/env bash

set -e # Exit upon error

# This script generates a 64-bit system
source "$SRC"/variables.sh
source "$SRC"/functions.sh

#----------------------------------------------------------------------------------------------------#
#                             C O N F I G U R E   I N S T A L L A T I O N                            #
#----------------------------------------------------------------------------------------------------#

# Display help messgae
function show_help() {
  cat <<EOF
Usage: ${0##*/} [temp-system|basic-system|configure-system|finalize-system]

Compile & install 64bit Panda Linux
EOF
}

# Show installation configuration information to the user
echo empty
echo warn "General Installation Configuration"
echo norm "${BOLD}Installation Directory:${NORM}    ${INSTALL_DIR}"
echo norm "${BOLD}Run tests:${NORM}                 ${MAKE_TESTS}"
echo norm "${BOLD}No. of jobs:${NORM}               ${MAKE_PARALLEL}"
echo norm "${BOLD}Target:${NORM}                    ${TARGET}"
echo norm "${BOLD}Path:${NORM}                      ${PATH}"
echo empty
echo norm "${BOLD}Tools Directory:${NORM}           /tools"
echo empty

# Validate path provided by the user
if [ ! -d "$INSTALL_DIR" ]; then
  echo warn "Creating $INSTALL_DIR"
  requireRoot mkdir -p "$INSTALL_DIR"
fi

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N                                  #
#----------------------------------------------------------------------------------------------------#

echo empty
echo success "Starting installation..."

# Copying data to the installation location
echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
cp -ur ./* "${INSTALL_DIR}"

case "$1" in
temp-system)
  # Constructing temporary system
  pushd "${TEMP_SYSTEM_DIR}" && bash init.sh && popd
  ;;

testChroot)
  testBootOrChroot
  ;;

basic-system)
  # Building the basic system
  pushd "${BUILD_SYSTEM_DIR}" && bash init.sh && popd
  ;;

configure-system)
  # Configuring the system
  pushd "${CONFIGURE_SYSTEM_DIR}" && bash init.sh && popd
  ;;

finalize-system)
  # Finalize the system
  pushd "${FINALIZE_SYSTEM_DIR}" && bash init.sh && popd
  ;;

*)
  echo error "Invalid option selected! Exiting..."
  exit 1
  ;;

esac

#----------------------------------------------------------------------------------------------------#
#                               F I N I S H   I N S T A L L A T I O N                                #
#----------------------------------------------------------------------------------------------------#

echo empty
echo warn "Removing installation files"
rm -rf "$SRC"
echo success "Done!"
