#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="grub"
PKG_VERSION="2.00"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The GRUB package contains the GRand Unified Bootloader."
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
    sed -i -e '/gets is a/d' grub-core/gnulib/stdio.in.h
    ./configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --disable-werror

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install

    install -m755 -dv /etc/default
    cat > /etc/default/grub << "EOF"
# Begin /etc/default/grub

GRUB_DEFAULT=0
#GRUB_SAVEDEFAULT=true
GRUB_HIDDEN_TIMEOUT=
GRUB_HIDDEN_TIMEOUT_QUIET=false
GRUB_TIMEOUT=10
GRUB_DISTRIBUTOR=Panda-Linux

GRUB_CMDLINE_LINUX=""
GRUB_CMDLINE_LINUX_DEFAULT=""

#GRUB_TERMINAL=console
#GRUB_GFXMODE=640x480
#GRUB_GFXPAYLOAD_LINUX=keep

#GRUB_DISABLE_LINUX_UUID=true
#GRUB_DISABLE_LINUX_RECOVERY=true

#GRUB_INIT_TUNE="480 440 1"

#GRUB_DISABLE_OS_PROBER=true

# End /etc/default/grub
EOF
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/usr/sbin/grub-install" ]; then
    touch DONE
fi