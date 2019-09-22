#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="binutils"
PKG_VERSION="2.32"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

LINK="http://ftp.gnu.org/gnu/$PKG_NAME/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Binutils package contains a linker, an assembler, and other tools for handling object files."
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
    CC="$TARGET"-gcc \
      AR="$TARGET"-ar \
      RANLIB="$TARGET"-ranlib \
      ../configure \
      --prefix=/tools \
      --with-sysroot \
      --with-lib-path=/tools/lib \
      --disable-nls \
      --disable-werror

  make "${MAKE_PARALLEL}"
}

function instal() {
  echo -e "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
  make -C ld clean
  make -C ld LIB_PATH=/usr/lib:/lib
  cp -v ld/ld-new /tools/bin
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
