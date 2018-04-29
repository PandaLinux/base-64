#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gcc"
PKG_VERSION="7.3.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The GCC package contains the GNU compiler collection, which includes the C and C++ compilers."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
    tar -xf ../../sources/mpfr-4.0.1.tar.xz && mv -v mpfr-4.0.1 mpfr
    tar -xf ../../sources/gmp-6.1.2.tar.xz && mv -v gmp-6.1.2 gmp
    tar -xf ../../sources/mpc-1.1.0.tar.gz && mv -v mpc-1.1.0 mpc
}

function build() {
    for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@"${HOST_TDIR}"&@g' \
      -e 's@/usr@"${HOST_TDIR}"@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "${HOST_TDIR}/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done
    
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
    
    mkdir   ${BUILD_DIR}  &&
    cd      ${BUILD_DIR}  &&

    ../configure --prefix=${HOST_TDIR}               \
                 --build=${HOST}                     \
                 --host=${TARGET}                    \
                 --target=${TARGET}                  \
                 --with-local-prefix=${HOST_TDIR}    \
                 --disable-multilib                  \
                 --enable-languages=c,c++            \
                 --with-system-zlib                  \
                 --with-native-system-header-dir=${HOST_TDIR}/include \
                 --disable-libssp                    \
                 --enable-install-libiberty
		 
		 
    ../configure                                       \
    --target=${TARGET}                              \
    --prefix=${HOST_TDIR}                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=${INSTALL_DIR}                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=${HOST_TDIR}                     \
    --with-native-system-header-dir=${HOST_TDIR}/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} mpfr gmp mpc
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${TOOLS_DIR}/bin/gcc ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi
