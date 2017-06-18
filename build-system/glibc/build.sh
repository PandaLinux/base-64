#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="glibc"
PKG_VERSION="2.25"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
TARBALL_TZDATA="tzdata2017b.tar.gz"

SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Glibc package contains the main C library. This library provides the basic routines for"
    echo -e "allocating memory, searching directories, opening and closing files, reading and writing files, string"
    echo -e "handling, pattern matching, arithmetic, and so on."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /sources/${TARBALL_TZDATA} ${TARBALL_TZDATA}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    LINKER=$(readelf -l ${HOST_TDIR}/bin/bash | sed -n "s@.*interpret.*${HOST_TDIR}\(.*\)]$@\1@p")
    sed -i "s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=${LINKER} -o|" \
            scripts/test-installation.pl
    unset LINKER

    sed -i '/RTLDLIST/d' sysdeps/unix/sysv/linux/*/ldd-rewrite.sed

    mkdir -pv   ${BUILD_DIR} &&
    cd          ${BUILD_DIR} &&

    echo "libc_cv_slibdir=/lib" >> config.cache

    ../configure --prefix=/usr                   \
                 --enable-kernel=3.12.0          \
                 --libexecdir=/usr/lib/glibc     \
                 --libdir=/usr/lib               \
                 --enable-obsolete-rpc           \
				 --enable-stack-protector=strong \
                 --cache-file=config.cache

    make ${MAKE_PARALLEL}
}

function runTest() {
     TIMEOUTFACTOR=16 make ${MAKE_PARALLEL} -k check || true
}

function instal() {
    touch /etc/ld.so.conf

    # Install the package, and remove unneeded files from /usr/include/rpcsvc
    make ${MAKE_PARALLEL} install &&
    rm -v /usr/include/rpcsvc/*.x

    # Install the configuration file and runtime directory for nscd
    cp -v ../nscd/nscd.conf /etc/nscd.conf
    mkdir -pv /var/cache/nscd

    # Install the systemd support files for nscd
    install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
    install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service

    # Internationalization
    mkdir -pv /usr/lib/locale
    localedef -i en_US -f ISO-8859-1 en_US
}

function configure() {
    # Create a new file /etc/nsswitch.conf
    cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

    # Install timezone data
    tar -xf ../../${TARBALL_TZDATA}

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv ${ZONEINFO}/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica  \
              asia australasia backward pacificnew \
              systemv; do
        zic -L /dev/null   -d ${ZONEINFO}       -y "sh yearistype.sh" ${tz}
        zic -L /dev/null   -d ${ZONEINFO}/posix -y "sh yearistype.sh" ${tz}
        zic -L leapseconds -d ${ZONEINFO}/right -y "sh yearistype.sh" ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab ${ZONEINFO}
    zic -d ${ZONEINFO} -p America/New_York
    unset ZONEINFO

    # Configure the dynamic loader
    cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf

/usr/local/lib

# End /etc/ld.so.conf
EOF
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${TARBALL_TZDATA}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;configure;popd;clean; }
# Verify installation
if [ -f /usr/bin/ldd ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi