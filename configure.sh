#!/usr/bin/env bash

set -e # Stop the script upon errors

## This is script configures the system and download all the necessary packages required
## for compiling the system from source.

source functions.sh
source variables.sh

function configureSys() {
    # Detect distribution name
    if [[ `which lsb_release 2>&1 /dev/null` ]]; then
        # lsb_release is available
        DISTRIB_NAME=`lsb_release -is`
    else
        # lsb_release is not available
        lsb_files=`find /etc -type f -maxdepth 1 \( ! -wholename /etc/os-release ! -wholename /etc/lsb-release -wholename /etc/\*release -o -wholename /etc/\*version \) 2> /dev/null`
        for file in $lsb_files; do
            if [[ $file =~ /etc/(.*)[-_] ]]; then
                DISTRIB_NAME=${BASH_REMATCH[1]}
                break
            else
                echo error "${BOLD}Sorry, Panda Linux cannot be complied from your system.${NORM}"
                exit 1
            fi
        done
    fi

    echo warn "Detected system: ${BOLD}$DISTRIB_NAME${NORM}"

    shopt -s nocasematch
    # Let's do the installation of missing packages
    if [[ $DISTRIB_NAME == "ubuntu" || $DISTRIB_NAME == "debian" ]]; then
        # Debian/Ubuntu
        # Set non interactive mode
        set -eo pipefail
        export DEBIAN_FRONTEND=noninteractive

        # Make sure the package repository is up to date
        requireRoot apt-get update -qq
        echo empty

        # Install prerequisites
        requireRoot apt-get install -qq --yes --force-yes bash binutils bison bzip2 build-essential coreutils diffutils \
            findutils gawk glibc-2.19-1 grep gzip make ncurses-dev patch perl sed tar texinfo xz-utils
        echo empty

        # Check version of the installed packages
        bash version-check.sh
        echo empty

        echo warn "Fixing bash symlink..."
        # Remove symlink /bin/sh
        requireRoot rm /bin/sh
        # Link `bash` to `sh`
        requireRoot ln -s /bin/bash /bin/sh
        echo success "Fixed symlink."

        # Make `install.sh` executable by default
        requireRoot chmod +x install.sh
        echo empty

        if [ ! $(cat /etc/passwd | grep ${PANDA_USER}) ]; then
            echo warn "Creating user ${PANDA_USER}..."
            requireRoot groupadd "${PANDA_GROUP}"
            requireRoot useradd -s /bin/bash -g "${PANDA_GROUP}" -d "/home/${PANDA_HOME}" "${PANDA_USER}"
            requireRoot mkdir -p "/home/${PANDA_HOME}"
            requireRoot passwd -d "${PANDA_USER}"
            echo success "User successfully setup!"
            echo empty
        fi

    else
        # Unsupported system
        echo norm "${REV}Panda Linux cannot be compiled from your system.${NORM}"
        exit 0
    fi

    shopt -u nocasematch

    if [ ! -f dummy.log ]; then
        # Download the required packages
        echo warn "wget --continue --input-file=wget-list --directory-prefix=${PWD}/sources"
        wget --continue --input-file=wget-list --directory-prefix="${PWD}/sources"
        echo empty

        # Copy all data to ${PANDA_HOME}
        requireRoot cp -rfu ./* "/home/${PANDA_HOME}"
        requireRoot chown -R ${PANDA_USER}:${PANDA_GROUP} /home/${PANDA_HOME}
        echo empty

        echo success "Your system is now configured!!"

        exit 0
    else
        echo error "Configuration failed! Fix your errors and try again later..."
        exit 1
    fi
}

time { configureSys; }