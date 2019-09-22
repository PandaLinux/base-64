#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

PKG_NAME="findutils"
PKG_VERSION="4.6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

LINK="http://ftp.gnu.org/gnu/$PKG_NAME/$TARBALL"

function showHelp() {
  echo -e "--------------------------------------------------------------------------------------------------------------"
  echo -e "Description: The Findutils package contains programs to find files. These programs are provided to recursively"
  echo -e "search through a directory tree and to create, maintain, and search a database (often faster than the"
  echo -e "recursive find, but unreliable if the database has not been recently updated)."
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
  sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
  sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
  echo "#define _IO_IN_BACKUP 0x100" >>gl/lib/stdio-impl.h

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
