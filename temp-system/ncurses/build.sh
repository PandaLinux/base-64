#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="ncurses"
PKG_VERSION="6.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

LINK="http://ftp.gnu.org/gnu/$PKG_NAME/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Ncurses package contains libraries for terminal-independent handling of character screens."
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e ""
}

function prepare() {
  echo -e "Downloading $TARBALL from $LINK"
  wget "$LINK" -O "$TARBALL"
}

function unpack() {
  techo -e "Unpacking $TARBALL"
  tar xf ${TARBALL}
}

function build() {
  echo -e "Configuring $PKG_NAME"
  sed -i s/mawk// configure
  ./configure --prefix=/tools \
    --with-shared \
    --without-debug \
    --without-ada \
    --enable-widec \
    --enable-overwrite
  make "$MAKE_PARALLEL"
}

function instal() {
  echo -e "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
  ln -s libncursesw.so /tools/lib/libncurses.so
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
