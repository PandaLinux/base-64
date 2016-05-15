#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

source "${INSTALL_DIR}/variables.sh"
source "${INSTALL_DIR}/functions.sh"

if [ -f "${TEMP_SYSTEM_DIR}/vim/DONE" ]; then
    echo norm 'export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin' >> "${CONFIG_FILE}"
    source "${CONFIG_FILE}"

    _list=(virtual-kernel-fs prepare-env testsuite-tools perl-temp linux-headers man-pages glibc adjust-toolchain m4 \
           gmp mpfr mpc isl cloog zlib flex bison flex binutils gcc attr acl ) # coreutils acl)

    for i in ${_list[@]}; do
        case $i in
            virtual-kernel-fs )
                pushd ${i}
                    if [ -e DONE ]; then
                        echo success "${i} --> Already Built"
                    else
                        echo empty
                        echo warn "Building ---> ${i}"
                        bash build.sh |& tee build.log

                        if [ -e DONE ]; then
                            echo success "Building ---> ${i} completed"
                        else
                            echo error "Building ---> ${i} failed"
                            exit 1
                        fi

                        echo empty
                    fi
                popd;;

            testsuite-tools )
                pushd ${i}
                    _testsuite_list=(tcl expect dejagnu)

                    for j in ${_testsuite_list[@]}; do
                        case $j in
                            * )
                                pushd ${j}
                                    if [ -e DONE ]; then
                                        echo success "${j} --> Already Built"
                                    else
                                        echo empty
                                        echo warn "Building ---> ${j}"
                                        chrootTmp "source /.config && pushd /build-system/testsuite-tools/${j} && bash build.sh |& tee build.log popd"

                                        if [ -e DONE ]; then
                                            echo success "Building ---> ${j} completed"
                                        else
                                            echo error "Building ---> ${i} failed"
                                            exit 1
                                        fi

                                        echo empty
                                    fi
                                popd;;
                        esac
                    done
                popd;;

            * )
                pushd ${i}
                    if [ -e DONE ]; then
                        echo success "${i} --> Already Built"
                    else
                        echo empty
                        echo warn "Building ---> ${i}"
                        chrootTmp "source /.config && pushd /build-system/${i} && bash build.sh |& tee build.log popd"

                        if [ -e DONE ]; then
                            echo success "Building ---> ${i} completed"
                        else
                            echo error "Building ---> ${i} failed"
                            exit 1
                        fi

                        echo empty
                    fi
                popd;;
        esac
    done
else
    echo error "Installation failed..."
    exit 1
fi
