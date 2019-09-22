#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="m4"
PKG_VERSION="1.4.18"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

LINK="http://ftp.gnu.org/gnu/$PKG_NAME/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The M4 package contains a macro processor."
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e ""
}

function prepare() {
  echo -e "Downloading $TARBALL from $LINK"
  wget "$LINK" -O "$TARBALL"
}

function unpack() {
  echo -e "Unpacking $TARBALL"
  tar xf ${TARBALL}
}

function build() {
  echo -e "Configuring $PKG_NAME"
  sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
  echo "#define _IO_IN_BACKUP 0x100" >>lib/stdio-impl.h

  ./configure --prefix=/tools
  make "$MAKE_PARALLEL"
}

function verify() {
  echo -e "Running tests for $PKG_NAME"
  make "$MAKE_PARALLEL" check
}

function instal() {
  echo -e "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
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
  verify
  instal
  popd
  clean
}
