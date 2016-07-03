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
        $*
    elif [[ -x /bin/sudo || -x /usr/bin/sudo ]]; then
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
		echo success "Finished!"
	else
		[ $# -gt 0 ] && echo error "$@" || echo error "Failed!"
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

        echo warn "Deleting user ${PANDA_USER} and /home/${PANDA_HOME}"
        requireRoot userdel ${PANDA_USER}
        requireRoot rm -rf /home/${PANDA_HOME}
    fi

    echo warn "Creating user ${PANDA_USER}..."
    requireRoot groupadd ${PANDA_GROUP}
    requireRoot useradd -s /bin/bash -g ${PANDA_GROUP} -d /home/${PANDA_HOME} ${PANDA_USER}
    requireRoot mkdir -p /home/${PANDA_HOME}
    echo empty

    read -p "${YELLOW}Do you want to set password for ${PANDA_USER}? [Y/n]:${NORM} " -n 1 -r
    echo empty
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        requireRoot passwd ${PANDA_USER}
    else
        requireRoot passwd -d ${PANDA_USER} > /dev/null
        echo empty
        echo warn "Add the following at the end of /etc/sudoers"
        echo empty
        echo bold "${PANDA_USER}	ALL=(ALL) NOPASSWD: ALL"
        echo empty
        echo warn "This will remove the password prompts for the user ${PANDA_USER}"
        echo empty
    fi

    requireRoot usermod -aG sudo ${PANDA_USER}

    # Copy all data to ${PANDA_HOME}
    echo warn "Copying data to '/home/${PANDA_HOME}'"
    requireRoot cp -r ./* /home/${PANDA_HOME}
	requireRoot chown -R ${PANDA_USER}:${PANDA_GROUP} /home/${PANDA_HOME}
    echo empty

    echo success "User has been successfully setup!"
}

# Verify that it is ${PANDA_USER}
function verify-user() {
    if [ ! `whoami` = ${PANDA_USER} ]; then
        echo error "Only ${PANDA_USER} can execute this script."
        exit 1
    fi
}

function setup-env() {
	echo norm "exec env -i HOME=${HOME} TERM=${TERM} PS1='\u:\w\$ ' /bin/bash" >  ~/.bash_profile
	echo norm "set +h" > ~/.bashrc
	echo norm "umask 022" >> ~/.bashrc
	echo norm "unset CFLAGS CXXFLAGS" >> ~/.bashrc

	# This sets up key mapping so the delete key works:
	cp /etc/inputrc ~/.inputrc > /dev/null

	list=(INSTALL_DIR TOOLS_DIR CROSS_DIR TARGET PATH PANDA_HOST BUILD64 MAKE_TESTS         \
          MAKE_PARALLEL LC_ALL VM_LINUZ SYSTEM_MAP DO_BACKUP HOST_TDIR HOST_CDIR ROOT_DIR   \
          DONE_DIR)
	for i in ${list[@]}; do
		echo norm "export $i=${!i}" >> ~/.bashrc
	done
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

function testBootOrChroot() {
	# Continue if building on and for the same arch
	if [ $(uname -m) != 'x86_64' ]; then
		echo empty
		echo warn "Testing the system!"
		${TOOLS_DIR}/lib/libc.so.6 > /dev/null && ${TOOLS_DIR}/bin/gcc --version > /dev/null
		checkCommand "Please submit this issue on our Github account!";
		# TODO: Add the script to prepare the system for booting procedure
	fi
}

# Cleans up the newly created system
function cleanup() {
	echo empty
	echo warn "Cleaning the system..."

	requireRoot rm -rf ${INSTALL_DIR}/{build-system,configure-system,cross-compile-tools,docs,finalize-system,patches,sources,temp-system}
	requireRoot rm -rf ${INSTALL_DIR}/{*.md,*.git*,*.sh,wget-list,md5sums}
	requireRoot rm -rf ${TOOLS_DIR} ${HOST_TDIR}
	requireRoot rm -rf ${CROSS_DIR} ${HOST_CDIR}
	checkCommand;
}
