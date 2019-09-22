#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="gcc"
PKG_VERSION="9.2.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

LINK="http://ftp.gnu.org/gnu/$PKG_NAME/$SRC_DIR/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: Libstdc++ is the standard C++ library. It is needed to compile C++."
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e ""
}

function prepare() {
  echo -e "Downloading $TARBALL from $LINK"
  wget "$WGET_OPTIONS" "$LINK" -O "$TARBALL"
}

function unpack() {
  echo -e "Unpacking $TARBALL"
  tar xf ${TARBALL}
}

function build() {
  echo -e "Configuring $PKG_NAME"
  mkdir ${BUILD_DIR} &&
    cd ${BUILD_DIR} &&
    ../libstdc++-v3/configure \
      --prefix=/tools \
      --host="$TARGET" \
      --disable-multilib \
      --disable-nls \
      --disable-libstdcxx-thread \
      --disable-libstdcxx-pch \
      --with-gxx-include-dir=/tools/"$TARGET"/include/c++/"$PKG_VERSION"

  make "${MAKE_PARALLEL}"
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
