#!/usr/bin/env bash

## This file contains all the function that will be used throughout the build process

# Override echo to colorize output
echo() {
    case $1 in
        success )
            command echo "${GREEN}$2${NORM}";;

        warn )
            command echo "${WARN}$2${NORM}";;

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