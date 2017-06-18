#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="vim"
PKG_VERSION="8.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}74"

PATCH=${PKG_NAME}-${PKG_VERSION}-branch_update-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Vim package contains a powerful text editor."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
    ln -sv ../../patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../${PATCH}

    cat > src/auto/config.cache << "EOF"
vim_cv_getcwd_broken=no
vim_cv_memmove_handles_overlap=yes
vim_cv_stat_ignores_slash=no
vim_cv_terminfo=yes
vim_cv_toupper_broken=no
vim_cv_tty_group=world
vim_cv_tgent=zero
EOF

    printf '#define SYS_VIMRC_FILE "%s/etc/vimrc"' "${HOST_TDIR}" >> src/feature.h

    ./configure --build=${HOST}          \
                --host=${TARGET}         \
                --prefix=${HOST_TDIR}    \
                --enable-gui=no          \
                --disable-gtktest        \
                --disable-xim            \
                --disable-gpm            \
                --without-x              \
                --disable-netbeans       \
                --with-tlib=ncurses

    make ${MAKE_PARALLEL}
}

function instal() {
    make -j1 install
    ln -sv vim ${HOST_TDIR}/bin/vi

    cat > ${HOST_TDIR}/etc/vimrc << "EOF"
" Begin

set nocompatible
set backspace=2
set ruler
syntax on

" End
EOF
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${TOOLS_DIR}/bin/vi ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi