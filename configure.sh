#!/usr/bin/env bash

## This is script configures the system and download all the necessary packages required
## for compiling the system from source.

source functions.sh
source variables.sh

function configureSys() {
    # Detect distribution name
    if [[ `which lsb_releaseX 2>&1 /dev/null` ]]; then
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
                echo "${BOLD}Sorry, Panda Linux cannot be complied from your system.${NORM}"
                exit 1
            fi
        done
    fi

    echo "${REV}Detected system${NORM}" ${BOLD}$DISTRIB_NAME${NORM}

    shopt -s nocasematch
    # Let's do the installation of missing packages
    if [[ $DISTRIB_NAME == "ubuntu" || $DISTRIB_NAME == "debian" ]]; then
        # Debian/Ubuntu
        # Set non interactive mode
        set -eo pipefail
        export DEBIAN_FRONTEND=noninteractive

        # Make sure the package repository is up to date
        requireRoot apt-get --yes --force-yes update

        # Install prerequisites
        requireRoot apt-get install --yes --force-yes bash binutils bison bzip2 build-essential coreutils diffutils \
            findutils gawk grep gzip make patch sed tar texinfo xz-utils

        # Check version of the installed packages
        bash version-check.sh 2>errors.log &&
        [ -s errors.log ] && echo -e "${REV}\nThe following packages could not be found:\n${NORM}$(cat errors.log)"

        # Remove symlink /bin/sh
        requireRoot rm -v /bin/sh
        # Link `bash` to `sh`
        requireRoot ln -sv /bin/bash /bin/sh

        # Make `install.sh` executable by default
        requireRoot chmod +x install.sh

        echo "${BOLD}Your system is now configured!!${NORM}"
        echo "${BOLD}You can now run ${REV}./install.sh${NORM}${BOLD} to continue...${NORM}"

    elif [[ $DISTRIB_NAME == "redhat" || $DISTRIB_NAME == "centos" || $DISTRIB_NAME == "Scientific" ]]; then
        # Redhat/CentOS/SL

        # TODO: Install debian/ubuntu image in a container using docker and then execute the rest of the script
        echo "${BOLD}TODO: Install debian/ubuntu image in a container using docker and then execute the rest of the script.${NORM}"
        echo "${BOLD}TODO: Please feel free to create a docker image and PR us at https://github.com/PandaLinux/base-64.${NORM}"

    elif [[ $DISTRIB_NAME == "fedora" ]]; then
        # Fedora

        # TODO: Install debian/ubuntu image in a container using docker and then execute the rest of the script
        echo "${BOLD}TODO: Install debian/ubuntu image in a container using docker and then execute the rest of the script.${NORM}"
        echo "${BOLD}TODO: Please feel free to create a docker image and PR us at https://github.com/PandaLinux/base-64.${NORM}"

    elif [[ $DISTRIB_NAME == "arch" ]]; then
        # Arch Linux

        # TODO: Install debian/ubuntu image in a container using docker and then execute the rest of the script
        echo "${BOLD}TODO: Install debian/ubuntu image in a container using docker and then execute the rest of the script.${NORM}"
        echo "${BOLD}TODO: Please feel free to create a docker image and PR us at https://github.com/PandaLinux/base-64.${NORM}"

    else
        # Unsupported system

        echo "${REV}Panda Linux cannot be compiled from your system.${NORM}"
        exit 1
    fi

    shopt -u nocasematch

    # Download the required packages
    echo "${BOLD}wget --continue --input-file=wget-list --directory-prefix=${PWD}/sources${NORM}"
    wget --continue --input-file=wget-list --directory-prefix="${PWD}/sources"
}

time { configureSys; }