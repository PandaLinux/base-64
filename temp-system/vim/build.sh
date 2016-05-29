#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="vim"
PKG_VERSION="7.4"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}74"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Vim package contains a powerful text editor."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "../../sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-branch_update-7.patch"

    cat > src/auto/config.cache << "EOF"
vim_cv_getcwd_broken=no
vim_cv_memmove_handles_overlap=yes
vim_cv_stat_ignores_slash=no
vim_cv_terminfo=yes
vim_cv_toupper_broken=no
vim_cv_tty_group=world
EOF

    printf '#define SYS_VIMRC_FILE "%s/etc/vimrc"' "${HOST_TOOLS_DIR}" >> src/feature.h

    ./configure --prefix="${HOST_TOOLS_DIR}"    \
                --build="${HOST}"               \
                --host="${TARGET}"              \
                --enable-gui=no                 \
                --disable-gtktest               \
                --disable-xim                   \
                --disable-gpm                   \
                --without-x                     \
                --disable-netbeans              \
                --with-tlib=ncurses

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install
    ln -sv vim "${HOST_TOOLS_DIR}/bin/vi"

    cat > "${HOST_TOOLS_DIR}/etc/vimrc" << "EOF"
" Begin

set nocompatible
set backspace=2
set ruler
syntax on

" End
EOF
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_TOOLS_DIR}/bin/vi" ]; then
    touch DONE
fi