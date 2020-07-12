#!/usr/bin/env bash

## This file contains all the function that will be used throughout the build process

# Override echo to colorize output
echo() {
  case $1 in
  success)
    command echo "${GREEN}$2${NORM}"
    ;;

  warn)
    command echo "${YELLOW}$2${NORM}"
    ;;

  error)
    command echo "${RED}$2${NORM}"
    ;;

  bold)
    command echo "${BOLD}$2${NORM}"
    ;;

  rev)
    command echo "${REV}$2${NORM}"
    ;;

  norm)
    command echo "$2"
    ;;

  empty)
    command echo ""
    ;;
  esac
}

# This script tries to run the command as `root`
function requireRoot() {
  # Already root?
  if [[ $(whoami) == 'root' ]]; then
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
  command pushd "$@" >/dev/null
}

# Override `popd` to dump data onto `/dev/null`
popd() {
  command popd "$@" >/dev/null
}

# Verify command ended successfully
function checkCommand() {
  if [ "$?" -eq 0 ]; then
    echo success "Finished!"
    echo empty
  else
    [ $# -gt 0 ] && echo error "$@" || echo error "Failed!"
    exit 1
  fi
}

# Override cp
cp() {
  command cp "$@"
  checkCommand
}

# Temporary chroot environment
function chrootTmp() {
  sudo mount --bind /dev "${INSTALL_DIR}"/dev
  sudo mount -t devpts devpts "${INSTALL_DIR}"/dev/pts
  sudo mount -t proc proc "${INSTALL_DIR}"/proc
  sudo mount -t sysfs sysfs "${INSTALL_DIR}"/sys
  sudo mount -t tmpfs tmpfs "${INSTALL_DIR}"/run

  sudo chroot "${INSTALL_DIR}" /tools/bin/env -i \
    HOME=/root TERM="${TERM}" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash -c "$@" +h

  sync && sleep 1
  sudo umount -l "${INSTALL_DIR}"/{run,sys,proc,dev/pts,dev}
}

# System chroot environment
function chrootSys() {
  sudo mount --bind /dev "${INSTALL_DIR}"/dev
  sudo mount -t devpts devpts "${INSTALL_DIR}"/dev/pts
  sudo mount -t proc proc "${INSTALL_DIR}"/proc
  sudo mount -t sysfs sysfs "${INSTALL_DIR}"/sys
  sudo mount -t tmpfs tmpfs "${INSTALL_DIR}"/run

  sudo chroot "${INSTALL_DIR}" /usr/bin/env -i \
    HOME=/root TERM="${TERM}" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash -c "$@" +h

  sync && sleep 1
  sudo umount -l "${INSTALL_DIR}"/{run,sys,proc,dev/pts,dev}
}

function testBootOrChroot() {
  # Continue if building on and for the same arch
  if [ "$(uname -m)" != 'x86_64' ]; then
    echo empty
    echo warn "Testing the system!"
    /tools/lib/libc.so.6 >/dev/null && /tools/bin/gcc --version >/dev/null
    checkCommand "Please submit this issue on our Github account!"
  fi
}

# Cleans up the newly created system
function cleanup() {
  echo empty
  echo warn "Cleaning the system..."

  requireRoot rm -rf "${INSTALL_DIR}"/{build-system,configure-system,cross-compile-tools,docs,finalize-system,patches,sources,temp-system}
  requireRoot rm -rf "${INSTALL_DIR}"/{*.md,*.git*,*.sh,wget-list,md5sums}
  requireRoot rm -rf "${INSTALL_DIR}"/tools
  checkCommand
}