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

        rev )
            command echo "${REV}$2${NORM}";;

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
        echo norm "$*"
        $*
    elif [[ -x /bin/sudo || -x /usr/bin/sudo ]]; then
        echo norm "sudo $*"
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

# Verify command ended successfully
function checkCommand() {
	if [ $? -eq 0 ]; then
		echo success "Finished"
	else
		echo error "Failed..."
        exit 1
	fi
}

# Override cp
cp() {
    command cp "$@"
    checkCommand;
}

# Temporary chroot environment
function chrootTmp() {
    sudo mount --bind /dev      ${INSTALL_DIR}/dev
    sudo mount -t devpts devpts ${INSTALL_DIR}/dev/pts
    sudo mount -t proc proc     ${INSTALL_DIR}/proc
    sudo mount -t sysfs sysfs   ${INSTALL_DIR}/sys
    sudo mount -t tmpfs tmpfs   ${INSTALL_DIR}/run

    sudo chroot ${INSTALL_DIR} ${HOST_TDIR}/bin/env -i  \
    HOME=/root TERM=${TERM} PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:${HOST_TDIR}/bin \
    ${HOST_TDIR}/bin/bash -c "$@" +h

    sync && sleep 1
    sudo umount -l ${INSTALL_DIR}/{run,sys,proc,dev/pts,dev}
}

# System chroot environment
function chrootSys() {
    sudo mount --bind /dev      ${INSTALL_DIR}/dev
    sudo mount -t devpts devpts ${INSTALL_DIR}/dev/pts
    sudo mount -t proc proc     ${INSTALL_DIR}/proc
    sudo mount -t sysfs sysfs   ${INSTALL_DIR}/sys
    sudo mount -t tmpfs tmpfs   ${INSTALL_DIR}/run

    sudo chroot ${INSTALL_DIR} /usr/bin/env -i  \
    HOME=/root TERM=${TERM} PS1='\u:\w\$ '      \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin          \
    /bin/bash -c "$@" +h

    sync && sleep 1
    sudo umount -l ${INSTALL_DIR}/{run,sys,proc,dev/pts,dev}
}

# This function setups the user for good
function setup-user() {
    # Setup the user if not already done
    if [ $(cat /etc/passwd | grep ${PANDA_USER}) ]; then
        echo error "User ${PANDA_USER} already exists!"
        echo warn "Continue if you wish to delete all previous data"

        askConfirm;

        echo warn "Deteing user ${PANDA_USER} and /home/${PANDA_HOME}"
        requireRoot userdel ${PANDA_USER}
        requireRoot rm -rf /home/${PANDA_HOME}
    fi

    echo warn "Creating user ${PANDA_USER}..."
    requireRoot groupadd ${PANDA_GROUP}
    requireRoot useradd -s /bin/bash -g ${PANDA_GROUP} -d /home/${PANDA_HOME} ${PANDA_USER}
    requireRoot mkdir -p /home/${PANDA_HOME}
    echo empty

    read -p "${YELLOW}Do you wan to set password for ${PANDA_USER}? [Y/n]:${NORM} " -n 1 -r
    echo empty
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        requireRoot passwd ${PANDA_USER}
    else
        requireRoot passwd -d ${PANDA_USER}
        echo warn "Add the following at the end of /etc/sudoers"
        echo bold "${PANDA_USER}	ALL=(ALL) NOPASSWD: ALL"
        echo empty
        echo warn "This will remove the password prompts for the user ${PANDA_USER}"
        echo empty
    fi

    requireRoot usermod -aG sudo ${PANDA_USER}
    echo success "User successfully setup!"
    echo empty

    # Copy all data to ${PANDA_HOME}
    echo warn "Moving data to '/home/${PANDA_HOME}'"
    sudo cp -r ./* /home/${PANDA_HOME}
    requireRoot chown -R ${PANDA_USER}:${PANDA_GROUP} /home/${PANDA_HOME}
    echo empty
}

# Verify that it is ${PANDA_USER}
function verify-user() {
    if [ ! `whoami` = ${PANDA_USER} ]; then
        echo error "Only ${PANDA_USER} can execute this script."
        exit 0
    fi
}

# Ask for confirmation to begin
function askConfirm() {
    read -p "${YELLOW}Continue? [Y/n]:${NORM} " -n 1 -r
    echo empty
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
    echo empty
}

# Creates backup
function createBackup() {
    if [ ${DO_BACKUP} = TRUE ]; then
        echo empty
        echo warn "Removing old backups..."
        requireRoot rm -f ${DIR}/backup.tar.bz2
        requireRoot rm -f ${INSTALL_DIR}/backup.tar.bz2

        echo empty
        echo warn "Creating new backup..."
        requireRoot tar -jcpPf ${DIR}/backup.tar.bz2 ${INSTALL_DIR}
        checkCommand;

        requireRoot chown -R `whoami` ${DIR}/backup.tar.bz2
    fi
}