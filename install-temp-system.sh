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
Usage: ${0##*/} [-i INSTALL_DIR] [-j CONCURRENT JOBS] [-t RUN TESTS] ...

Compile & install 64bit Panda Linux

Note: If you decide not to use any arguments, the previously set values will
be used by default.

    -h          Display this help and exit

    -i          Sets the installation directory.

    -j          Run concurrent jobs. Defaults to value in nproc.
                    0       - Uses all cores
                    1       - Any number onwards 1 no. of core(s) will be used

    -r          Resets options to their default value

    -t          Whether to run all the tests. Defaults to TRUE.
                    TRUE    - Run
                    FALSE   - Don't run

EOF
}

# Parse options
while getopts ":t:j:i:h:r:" opt; do
  case ${opt} in

  h)
    show_help
    exit 1
    ;;

  i)
    # Validate path provided by the user
    # Make sure a filesystem is mounted on this provided path
    sed -i "s#.*INSTALL_DIR=.*#INSTALL_DIR=${OPTARG}#" variables.sh
    ;;

  j)
    if [ "${OPTARG}" -eq 0 ]; then
      sed -i "s#.*MAKE_PARALLEL=.*#MAKE_PARALLEL=-j$(cat /proc/cpuinfo | grep -c processor)#" variables.sh
    else
      sed -i "s#.*MAKE_PARALLEL=.*#MAKE_PARALLEL=-j${OPTARG}#" variables.sh
    fi
    ;;

  r)
    sed -i "s#.*INSTALL_DIR=.*#INSTALL_DIR=/tmp/panda64#" variables.sh
    sed -i "s#.*MAKE_PARALLEL=.*#MAKE_PARALLEL=-j$(cat /proc/cpuinfo | grep -c processor)#" variables.sh
    sed -i "s#.*MAKE_TESTS=.*#MAKE_TESTS=TRUE#" variables.sh
    ;;

  t)
    if [ "${OPTARG}" = TRUE ] || [ "${OPTARG}" = FALSE ]; then
      sed -i "s#.*MAKE_TESTS=.*#MAKE_TESTS=${OPTARG}#" variables.sh
    else
      echo error "Invalid argument. -t only takes either 'TRUE' or 'FALSE'."
      exit 1
    fi
    ;;

  \?)
    echo error "Invalid option: -{$OPTARG}" >&2
    exit 1
    ;;

  :)
    echo error "Option -${OPTARG} requires an argument."
    exit 1
    ;;
  esac
done

source "${SRC}"/variables.sh

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
  requireRoot mkdir -p "$INSTALL_DIR"
fi

if [ ! -d "${INSTALL_DIR}"/dev ]; then
  # Get ${INSTALL_DIR} permissions
  requireRoot chown -R $(whoami) "${INSTALL_DIR}"
  # Create necessary directories and symlinks
  echo warn "Creating necessary folders..."

  if [ $(readlink /tools) ]; then
    requireRoot rm -rf /tools
  fi

  install -d "${INSTALL_DIR}"/tools
  install -d "${LOGS_DIR}"
  install -d "${DONE_DIR}"

  requireRoot ln -s "${INSTALL_DIR}"/tools /
fi

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N                                  #
#----------------------------------------------------------------------------------------------------#

echo empty
echo success "Starting installation..."
echo empty

# Copying data to the installation location
echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
cp -ur ./* "${INSTALL_DIR}"

# Constructing temporary system
pushd "${TEMP_SYSTEM_DIR}" && bash init.sh && popd
