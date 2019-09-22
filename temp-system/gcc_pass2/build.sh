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
  echo -e "Description: The GCC package contains the GNU compiler collection, which includes the C and C++ compilers."
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
  cat gcc/limitx.h gcc/glimits.h gcc/limity.h >$(dirname $("$TARGET"-gcc -print-libgcc-file-name))/include-fixed/limits.h

  for file in gcc/config/{linux,i386/linux{,64}}.h; do
    cp -uv $file{,.orig}
    sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig >$file
    echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >>$file
    touch $file.orig
  done

  case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
      -i.orig gcc/config/i386/t-linux64
    ;;
  esac

  ./contrib/download_prerequisites &&
    mkdir ${BUILD_DIR} &&
    cd ${BUILD_DIR} &&
    CC="$TARGET"-gcc \
      CXX="$TARGET"-g++ \
      AR="$TARGET"-ar \
      RANLIB="$TARGET"-ranlib \
      ../configure \
      --prefix=/tools \
      --with-local-prefix=/tools \
      --with-native-system-header-dir=/tools/include \
      --enable-languages=c,c++ \
      --disable-libstdcxx-pch \
      --disable-multilib \
      --disable-bootstrap \
      --disable-libgomp

  make "${MAKE_PARALLEL}"
}

function instal() {
  echo -e "Installing $PKG_NAME"
  make "${MAKE_PARALLEL}" install
  ln -sv gcc /tools/bin/cc
}

function verify() {
  echo 'int main(){}' >verify.c
  cc verify.c
  VERIFY=$(readelf -l a.out | grep ': /tools')
  echo "$VERIFY"
  if [ -z "$VERIFY" ]; then
    echo error "CC is not installed properly, exiting..."
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
