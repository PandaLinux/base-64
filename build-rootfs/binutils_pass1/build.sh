#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

source ../../variables.sh
source ../../functions.sh

PKG_NAME="binutils"
PKG_VERSION="2.34"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Binutils package contains a linker, an assembler, and other tools for handling object files."
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e ""
}

function prepare() {
  downloadSrc "gnu" "${PKG_NAME}" "${TARBALL}" "$(pwd)"
}

function unpack() {
  echo warn "Unpacking $TARBALL"
  tar xf ${TARBALL}
}

function build() {
  echo warn "Configuring $PKG_NAME"
  mkdir ${BUILD_DIR} &&
    cd ${BUILD_DIR} &&
    ../configure --prefix="${INSTALL_DIR}" \
      --with-sysroot=$LFS \
      --with-lib-path="${INSTALL_DIR}"/lib \
      --target=$LFS_TGT \
      --disable-nls \
      --disable-werror

  make "${MAKE_PARALLEL}"

  mkdir -v "${INSTALL_DIR}"/lib && ln -sv lib "${INSTALL_DIR}"/lib64
}

function runInstall() {
  echo warn "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
}

function clean() {
  echo warn "Cleaning up..."
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
  runInstall
  popd
  clean
}
