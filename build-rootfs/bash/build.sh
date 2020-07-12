#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

source ../../functions.sh

PKG_NAME="bash"
PKG_VERSION="5.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Bash package contains the Bourne-Again SHell."
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e ""
}

function prepare() {
  downloadSrc "gnu" "${PKG_NAME}" "${TARBALL}" "$(pwd)"
}

function unpack() {
  echo -e "Unpacking $TARBALL"
  tar xf ${TARBALL}
}

function build() {
  echo -e "Configuring $PKG_NAME"
  ./configure --prefix="${INSTALL_DIR}" --without-bash-malloc
  make "$MAKE_PARALLEL"
}

function instal() {
  echo -e "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
  ln -sv bash "${INSTALL_DIR}"/bin/sh
}

function clean() {
  echo -e "Cleaning up..."
  rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time {
  showHelp
  clean
  prepare
  unpack
  pushd ${SRC_DIR}
  build
  instal
  popd
  clean
}
