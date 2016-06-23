#!/usr/bin/env bash

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
            findutils gawk glibc-2.19-1 grep gzip make ncurses-dev openssl patch perl sed tar texinfo xz-utils
        echo empty

        # Check wget version
        wget_cur_ver=$(wget --version | head -n1 | cut -d" " -f3)

        if [ "$(printf "1.16\n$wget_cur_ver" | sort -V | head -n1)" = "${wget_cur_ver}" ] && [ "${wget_cur_ver}" != "1.16" ]; then
            echo warn "Setting up wget 1.16..."
            # On Ubuntu 14.04 wget is 1.15 but we want 1.16.3
            wget -c http://ftp.gnu.org/gnu/wget/wget-1.16.3.tar.gz
            tar -xf wget-1.16.3.tar.gz
            cd wget-1.16.3/
            ./configure  --prefix=/usr/local \
                         --sysconfdir=/etc
            make
            requireRoot make install
            requireRoot ln -fsv /usr/local/bin/wget /usr/bin/wget
            cd ../
            requireRoot rm -rf wget-1.16.3
            echo empty
            echo bold "Wget: v$(wget --version | head -n1 | cut -d" " -f3)"
            echo success "Finished"
        fi

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

    else
        # Unsupported system
        echo norm "${REV}Panda Linux cannot be compiled from your system.${NORM}"
        exit 0
    fi

    shopt -u nocasematch

    if [ ! -f dummy.log ]; then
        # Verify that all the packages have been downloaded
        if [ $(du -b ${DIR}/sources | cut -f1) -eq 429212074 ]; then
            echo success "Packages have already been downloaded. Skipping this step!"
        else
            # Download the required packages
            echo warn "Downloading packages..."
            requireRoot wget --continue --input-file=wget-list --directory-prefix=${DIR}/sources --quiet --show-progress || true
            echo success "Finished downloading..."
            echo empty
        fi

        echo success "Your system is now configured!!"
        echo empty
    else
        echo error "Configuration failed! Fix your errors and try again later..."
        exit 0
    fi
}

# Configure System
configureSys;

# Setup dedicated user
setup-user;
sudo su "${PANDA_USER}" -c 'echo "exec env -i HOME=${HOME} TERM=${TERM} PS1="\u:\w\$ " /bin/bash" > ~/.bash_profile'
sudo su "${PANDA_USER}" -c 'echo "set +h" > ~/.bashrc'
sudo su "${PANDA_USER}" -c 'echo "umask 022" >> ~/.bashrc'
sudo su "${PANDA_USER}" -c 'echo "unset CFLAGS CXXFLAGS" >> ~/.bashrc'

list=(INSTALL_DIR TOOLS_DIR CROSS_DIR TARGET PATH PANDA_HOST BUILD64 MAKE_TESTS         \
      MAKE_PARALLEL LC_ALL VM_LINUZ SYSTEM_MAP DO_BACKUP HOST_TDIR HOST_CDIR ROOT_DIR   \
      DONE_DIR)
for i in ${list[@]}; do
    sudo su "${PANDA_USER}" -c ". variables.sh && echo 'export $i=${!i}' >> ~/.bashrc"
done

echo success "Environment is now ready!!"
echo empty
