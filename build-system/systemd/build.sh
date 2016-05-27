#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="systemd"
PKG_VERSION="213"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The systemd package is a system and service manager for Linux operating systems."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "/sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-compat-1.patch"

    sed -i '/virt-install-hook /d' Makefile.in
    sed -i '/timesyncd.conf/d' src/timesync/timesyncd.conf.in
    sed -i '/-l/d' src/fsck/fsck.c

    ./configure --prefix=/usr                                                   \
                --sysconfdir=/etc                                               \
                --localstatedir=/var                                            \
                --libexecdir=/usr/lib                                           \
                --with-rootprefix=""                                            \
                --with-rootlibdir=/lib                                          \
                --enable-split-usr                                              \
                --disable-gudev                                                 \
                --with-kbd-loadkeys=/bin/loadkeys                               \
                --with-kbd-setfont=/bin/setfont                                 \
                --with-dbuspolicydir=/etc/dbus-1/system.d                       \
                --with-dbusinterfacedir=/usr/share/dbus-1/interfaces            \
                --with-dbussessionservicedir=/usr/share/dbus-1/services         \
                --with-dbussystemservicedir=/usr/share/dbus-1/system-services   \
                cc_cv_CFLAGS__flto=no

    make "${MAKE_PARALLEL}"
}

function test() {
    set +e
    sed -e "s:test/udev-test.pl::g" \
        -e "s:test-bus-cleanup\$(EXEEXT) ::g" \
        -e "s:test-bus-gvariant\$(EXEEXT) ::g" \
        -i Makefile
    make "${MAKE_PARALLEL}" check
    set -e
}

function instal() {
    make "${MAKE_PARALLEL}" install
    mv -v /usr/lib/libnss_myhostname.so.2 /lib
    rm -rfv /usr/lib/rpm

    for tool in runlevel reboot shutdown poweroff halt telinit; do
        ln -sfv ../bin/systemctl /sbin/$tool
    done
    ln -sfv ../lib/systemd/systemd /sbin/init

    sed -i "s@root lock@root root@g" /usr/lib/tmpfiles.d/legacy.conf
}

function configure() {
    systemd-machine-id-setup
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;configure;popd;clean; }
# Verify installation
if [ -f "/sbin/init" ]; then
    touch DONE
fi