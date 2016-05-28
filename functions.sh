#!/usr/bin/env bash

## This file contains all the function that will be used throughout the build process

# Override echo to colorize output
echo() {
    case $1 in
        success )
            command echo "${GREEN}$2${NORM}";;

        warn )
            command echo "${YELLOW}$2${NORM}";;

        error )
            command echo "${RED}$2${NORM}";;

        bold )
            command echo "${BOLD}$2${NORM}";;

        norm )
            command echo "$2";;

        empty )
            command echo "";;
    esac
}

# This script tries to run the command as `root`
function requireRoot() {
    # Already root?
    if [[ `whoami` == 'root' ]]; then
        echo bold "$*"
        $*
    elif [[ -x /bin/sudo || -x /usr/bin/sudo ]]; then
        echo bold "sudo $*"
        sudo $*
    else
        echo error "We require root privileges to install."
        echo error "Please run the script as root."
        echo empty
        exit 1
    fi
}

# Override `pushd` to dump data onto `/dev/null`
pushd() {
    command pushd "$@" > /dev/null
}

# Override `popd` to dump data onto `/dev/null`
popd() {
    command popd "$@" > /dev/null
}

# Override cp
cp() {
    command cp "$@"
    if [ $? -eq 0 ]; then
        echo success "Finished copying..."
    else
        echo error "Copying failed..."
        exit 1
    fi
}

# Temporary chroot environment
function chrootTmp() {
    sudo mknod -m 600 "${INSTALL_DIR}/dev/console" c 5 1
    sudo mknod -m 666 "${INSTALL_DIR}/dev/null" c 1 3

    sudo mount -o bind /dev "${INSTALL_DIR}/dev"
    sudo mount -t devpts -o gid=5,mode=620 devpts "${INSTALL_DIR}/dev/pts"
    sudo mount -t proc proc "${INSTALL_DIR}/proc"
    sudo mount -t tmpfs tmpfs "${INSTALL_DIR}/run"
    sudo mount -t sysfs sysfs "${INSTALL_DIR}/sys"

    sudo chroot "${INSTALL_DIR}" "${HOST_TOOLS_DIR}/bin/env" -i\
    HOME=/root TERM="${TERM}" PS1='\u:\w\$ '                   \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:${HOST_TOOLS_DIR}/bin   \
    ${HOST_TOOLS_DIR}/bin/bash -c "$@" +h

    sync && sleep 1

    sudo umount -l ${INSTALL_DIR}/{sys,run,proc,dev/pts,dev}
    sudo rm -rf ${INSTALL_DIR}/dev/{console,null}
}

# System chroot environment
function chrootSys() {
    sudo mknod -m 600 "${INSTALL_DIR}/dev/console" c 5 1
    sudo mknod -m 666 "${INSTALL_DIR}/dev/null" c 1 3

    sudo mount -o bind /dev "${INSTALL_DIR}/dev"
    sudo mount -t devpts -o gid=5,mode=620 devpts "${INSTALL_DIR}/dev/pts"
    sudo mount -t proc proc "${INSTALL_DIR}/proc"
    sudo mount -t tmpfs tmpfs "${INSTALL_DIR}/run"
    sudo mount -t sysfs sysfs "${INSTALL_DIR}/sys"

    sudo chroot "${INSTALL_DIR}" "${HOST_TOOLS_DIR}/bin/env" -i\
    HOME=/root TERM="${TERM}" PS1='\u:\w\$ '                   \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin                         \
    ${HOST_TOOLS_DIR}/bin/bash -c "$@" +h

    sync && sleep 1

    sudo umount -l ${INSTALL_DIR}/{sys,run,proc,dev/pts,dev}
    sudo rm -rf ${INSTALL_DIR}/dev/{console,null}
}