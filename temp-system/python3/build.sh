#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="python"
PKG_VERSION="3.7.4"

TARBALL="Python-${PKG_VERSION}.tar.xz"
SRC_DIR="Python-${PKG_VERSION}"

LINK="https://www.python.org/ftp/$PKG_NAME/$PKG_VERSION/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Python 3 package contains the Python development environment. It is useful for "
  echo -e "object-oriented programming, writing scripts, prototyping large programs or developing entire applications."
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

  sed -i '/def add_multiarch_paths/a \        return' setup.py
  ./configure --prefix=/tools --without-ensurepip
  make "$MAKE_PARALLEL"
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
  instal
  popd
  clean
}
