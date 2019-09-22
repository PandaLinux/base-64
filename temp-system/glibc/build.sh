#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="glibc"
PKG_VERSION="2.30"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

LINK="http://ftp.gnu.org/gnu/$PKG_NAME/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Glibc package contains the main C library."
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
    ../configure \
      --prefix=/tools \
      --host="$TARGET" \
      --build="$(../scripts/config.guess)" \
      --enable-kernel=3.2 \
      --with-headers=/tools/include

  make "${MAKE_PARALLEL}"
}

function instal() {
  echo -e "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
}

function verify(){
  echo 'int main(){}' > verify.c
  "$TARGET"-gcc verify.c
  VERIFY=$(readelf -l a.out | grep ': /tools')
  echo "$VERIFY"
  if [ -z "$VERIFY" ]; then
    echo error "$TARGET-gcc is not installed properly, exiting..."
    exit 1
  fi
}

function clean() {
  echo -e "Cleaning up..."
  rm -rf ${SRC_DIR} ${TARBALL} a.out verify.c
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
  verify
  popd
  clean
}
