#!/usr/bin/env bash

set -e # Exit upon error

SRC="$(pwd)"

# This script generates a 64-bit system
source "$SRC"/variables.sh
source "$SRC"/functions.sh

#----------------------------------------------------------------------------------------------------#
#                             C O N F I G U R E   I N S T A L L A T I O N                            #
#----------------------------------------------------------------------------------------------------#

# Display help messgae
function show_help() {
  cat <<EOF
Usage: ${0##*/} [build-rootfs|basic-system|configure-system|finalize-system]

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

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N                                  #
#----------------------------------------------------------------------------------------------------#

echo empty
echo success "Starting installation..."

case "$1" in
build-rootfs)
  # Remove install directory to keep clean builds
  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "${INSTALL_DIR}"
  fi

  echo warn "Creating $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  mkdir -p "${INSTALL_DIR}/bin"
  mkdir -p "${INSTALL_DIR}/etc"
  mkdir -p "${INSTALL_DIR}/dev"
  mkdir -p "${INSTALL_DIR}/etc"
  mkdir -p "${INSTALL_DIR}/proc"
  mkdir -p "${INSTALL_DIR}/run"
  mkdir -p "${INSTALL_DIR}/sbin"

  # Constructing root filesystem
  pushd "build-rootfs" && bash init.sh && popd
  ;;

testChroot)
  testBootOrChroot
  ;;

basic-system)
  # Building the basic system
  pushd "build-system" && bash init.sh && popd
  ;;

configure-system)
  # Configuring the system
  pushd "configure-system" && bash init.sh && popd
  ;;

finalize-system)
  # Finalize the system
  pushd "finalize-system" && bash init.sh && popd
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
echo success "Done!"
