#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
#set -e 		# Exit on error

PKG_NAME="glibc"
PKG_VERSION="2.19"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
TARBALL_TZDATA="tzdata2014d.tar.gz"

SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Glibc package contains the main C library. This library provides the basic routines for"
    echo -e "allocating memory, searching directories, opening and closing files, reading and writing files, string"
    echo -e "handling, pattern matching, arithmetic, and so on."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "/sources/$TARBALL" "$TARBALL"
    ln -sv "/sources/$TARBALL_TZDATA" "$TARBALL_TZDATA"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    LINKER=$(readelf -l ${HOST_TOOLS_DIR}/bin/bash | sed -n "s@.*interpret.*${HOST_TOOLS_DIR}\(.*\)]$@\1@p")
    sed -i "s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=${LINKER} -o|" \
            scripts/test-installation.pl
    unset LINKER

    sed -i 's/\\$$(pwd)/`pwd`/' timezone/Makefile

    mkdir -pv   "${BUILD_DIR}" &&
    cd          "${BUILD_DIR}" &&

    echo "slibdir=/lib" >> configparms

    ../configure --prefix=/usr                  \
                 --disable-profile              \
                 --enable-kernel=2.6.32         \
                 --libexecdir=/usr/lib/glibc    \
                 --libdir=/usr/lib              \
                 --enable-obsolete-rpc

    make "${MAKE_PARALLEL}"
}

function test() {
    make "${MAKE_PARALLEL}" -k check 2>&1 |& tee ../../glibc-check-log; grep Error ../../glibc-check-log
}

function instal() {
    touch /etc/ld.so.conf
    # Create a symlink to the real loader
    ln -sv ld-2.19.so /lib/ld-linux.so.2

    # Install the package, and remove unneeded files from /usr/include/rpcsvc
    make "${MAKE_PARALLEL}" install &&
    rm -v /usr/include/rpcsvc/*.x

    # Now we can remove this symlink. We also need to correct the /usr/bin/ldd script
    rm -v /lib/ld-linux.so.2
    sed -i.bak '/RTLDLIST/s%/ld-linux.so.2 /lib64%%' /usr/bin/ldd

    # Check the script to make sure the sed worked correctly, then delete the backup
    rm -v /usr/bin/ldd.bak

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
    tar -xf ../../"${TARBALL_TZDATA}"

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}

    for tz in etcetera southamerica northamerica europe africa antarctica  \
              asia australasia backward pacificnew \
              systemv; do
        zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
        zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
        zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
    done

    cp -v zone.tab iso3166.tab $ZONEINFO
    zic -d $ZONEINFO -p America/New_York
    unset ZONEINFO

    # Configure the dynamic loader
    cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf

/usr/local/lib
/opt/lib

# End /etc/ld.so.conf
EOF
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}" "${TARBALL_TZDATA}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;configure;popd;clean; }
# Verify installation
if [ -f "/usr/bin/ldd" ]; then
    touch DONE
fi