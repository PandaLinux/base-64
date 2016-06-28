#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

source ${HOME}/variables.sh
source ${HOME}/functions.sh

verify-user;

echo warn "Building the actual system..."

# Create log directory
LOGS_DIR_BUILD_SYSTEM=${LOGS_DIR}/build-system
install -d ${LOGS_DIR_BUILD_SYSTEM}
# Create DONE directory
DONE_DIR_BUILD_SYSTEM=${DONE_DIR}/build-system
install -d ${DONE_DIR_BUILD_SYSTEM}

export DONE_DIR_BUILD_SYSTEM
export LOGS_DIR_BUILD_SYSTEM=/logs/build-system

if [ -f ${DONE_DIR}/temp-system/xz-utils ]; then

    _list=(virtual-kernel-fs prepare-env testsuite-tools perl-temp linux-headers man-pages glibc adjust-toolchain m4    \
           gmp mpfr mpc isl zlib flex bison flex binutils gcc attr acl sed pkg-config-lite ncurses shadow util-linux-1  \
           procps-ng e2fsprogs libcap coreutils acl iana-etc libtool iproute2 bzip2 gdbm perl readline autoconf automake\
           bash bc diffutils file gawk findutils gettext gperf grep groff less gzip ip-utils kbd libpipeline man-db make\
           xz-utils expat xml-parser intltool kmod patch psmisc systemd dbus tar texinfo util-linux-2 vim grub clean)

    for i in ${_list[@]}; do
        case $i in
            virtual-kernel-fs )
                pushd ${i}
                    if [ -f ${DONE_DIR_BUILD_SYSTEM}/${i} ]; then
                        echo success "${i} --> Already Built"
                    else
                        echo empty
                        echo warn "Building ---> ${i}"
                        bash build.sh

                        if [ -f ${DONE_DIR_BUILD_SYSTEM}/${i} ]; then
                            echo success "Building ---> ${i} completed"
                        else
                            echo error "Building ---> ${i} failed"
                            exit 1
                        fi

                        echo empty
                    fi
                popd;;

            testsuite-tools )
                if [ ${MAKE_TESTS} = TRUE ]; then
					_testsuite_list=(tcl expect dejagnu)

                    for j in ${_testsuite_list[@]}; do
                        case $j in
                            * )
                                if [ -f ${DONE_DIR_BUILD_SYSTEM}/${j} ]; then
                                    echo success "${j} --> Already Built"
								else
                                    echo empty
                                    echo warn "Building ---> ${j}"
                                    chrootTmp "source /.vars && pushd /$(basename $(pwd))/testsuite-tools/${j} && bash build.sh |& tee ${LOGS_DIR_BUILD_SYSTEM}/${j}.log && popd"

                                    if [ -f ${DONE_DIR_BUILD_SYSTEM}/${j} ]; then
                                        echo success "Building ---> ${j} completed"
                                    else
                                        echo error "Building ---> ${j} failed"
                                        echo error "See ${LOGS_DIR_BUILD_SYSTEM}/${j}.log for more details..."
                                        exit 1
                                    fi

                                    echo empty
                                fi;;
                            esac
                        done
                fi;;

            clean )
				if [ -f ${DONE_DIR_BUILD_SYSTEM}/${i} ]; then
                    echo success "System already cleaned"
				else
                    echo empty
                    echo warn "Cleaning system..."
                    chrootSys "source /.vars && pushd /$(basename $(pwd))/clean && bash build.sh |& tee ${LOGS_DIR_BUILD_SYSTEM}/${i}.log && popd"

                    if [ -f ${DONE_DIR_BUILD_SYSTEM}/${i} ]; then
                        echo success "Cleaning completed"
					else
                        echo error "Cleaning failed"
                        exit 1
					fi

                    echo empty
				fi;;

            * )
				if [ -f ${DONE_DIR_BUILD_SYSTEM}/${i} ]; then
			        echo success "${i} --> Already Built"
                else
					echo empty
                    echo warn "Building ---> ${i}"
                    chrootTmp "source /.vars && pushd /$(basename $(pwd))/${i} && bash build.sh |& tee ${LOGS_DIR_BUILD_SYSTEM}/${i}.log && popd"

                    if [ -f ${DONE_DIR_BUILD_SYSTEM}/${i} ]; then
                        echo success "Building ---> ${i} completed"
					else
                        echo error "Building ---> ${i} failed"
                        echo error "See ${LOGS_DIR_BUILD_SYSTEM}/${i}.log for more details..."
                        exit 1
					fi

					echo empty
                fi;;
        esac
    done
fi

echo empty