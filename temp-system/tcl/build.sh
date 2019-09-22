#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="tcl"
PKG_VERSION="8.6.9"

TARBALL="${PKG_NAME}${PKG_VERSION}-src.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

LINK="https://downloads.sourceforge.net/$PKG_NAME/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The TCL packahe contains the Tool Command Language."
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
  cd unix
  ./configure --prefix=/tools

  make "${MAKE_PARALLEL}"
}

function tests() {
  echo -e "Running tests for $PKG_NAME"
  TZ=UTC make "$MAKE_PARALLEL" test
}

function instal() {
  echo -e "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
  chmod -v u+w /tools/lib/libtcl8.6.so
  make "$MAKE_PARALLEL" install-private-headers
  ln -sv tclsh8.6 /tools/bin/tclsh
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
  tests
  instal
  popd
  clean
}
