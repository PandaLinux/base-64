#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="bison"
PKG_VERSION="3.4.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"


function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Bison package contains a parser generator."
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
  ./configure --prefix=/tools --without-bash-malloc
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
