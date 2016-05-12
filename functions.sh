#!/usr/bin/env bash

## This file contains all the function that will be used throughout the build process

source variables.sh

function requireRoot() {
    # Already root?
    if [[ `whoami` == 'root' ]]; then
        $*
    elif [[ -x /bin/sudo || -x /usr/bin/sudo ]]; then
        echo "${BOLD}sudo $*${NORM}"
        sudo $*
    else
        echo "${REV}We require root privileges to install.${NORM}"
        echo "${REV}Please run the script as root.${NORM}"
        exit 1
    fi
}