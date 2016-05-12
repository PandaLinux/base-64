#!/usr/bin/env bash

## This file contains all the function that will be used throughout the build process

function requireRoot() {
    # Already root?
    if [[ `whoami` == 'root' ]]; then
        echo "${BOLD}S*${NORM}"
        $*
    elif [[ -x /bin/sudo || -x /usr/bin/sudo ]]; then
        echo "${BOLD}sudo $*${NORM}"
        sudo $*
    else
        echos error "${REV}We require root privileges to install.${NORM}"
        echos error "${REV}Please run the script as root.${NORM}"
        exit 1
    fi
}

function echos() {
    case $1 in
        success )
            echo "${GREEN}$2${NORM}";;

        warn )
            echo "${WARN}$2${NORM}";;

        error )
            echo "${RED}$2${NORM}";;

        bold )
            echo "${BOLD}$2${NORM}";;

        empty )
            echo "";;
    esac
}