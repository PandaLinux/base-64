#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="bash"
PKG_VERSION="4.4"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH=${PKG_NAME}-${PKG_VERSION}-branch_update-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Bash package contains the Bourne-Again SHell."
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

    cat > config.cache << "EOF"
ac_cv_func_mmap_fixed_mapped=yes
ac_cv_func_strcoll_works=yes
ac_cv_func_working_mktime=yes
bash_cv_func_sigsetjmp=present
bash_cv_getcwd_malloc=yes
bash_cv_job_control_missing=present
bash_cv_printf_a_format=yes
bash_cv_sys_named_pipes=present
bash_cv_ulimit_maxfds=yes
bash_cv_under_sys_siglist=yes
bash_cv_unusable_rtsigs=no
gt_cv_int_divbyzero_sigfpe=yes
EOF

    ./configure --prefix=${HOST_TDIR}   \
                --build=${HOST}         \
                --host=${TARGET}        \
                --without-bash-malloc   \
                --cache-file=config.cache

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${TOOLS_DIR}/bin/bash ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi