#!/usr/bin/env bash

set -e # Exit upon error

# This script generates a 64-bit system
source variables.sh
source functions.sh

# This script should only be executed by $PANDA_USER
verify-user;
# Setup the environment for the installation
setup-env;


#----------------------------------------------------------------------------------------------------#
#                             C O N F I G U R E   I N S T A L L A T I O N                            #
#----------------------------------------------------------------------------------------------------#

# Display help messgae
function show_help() {
    cat << EOF
Usage: ${0##*/} [-i INSTALL_DIR] [-j CONCURRENT JOBS] [-t RUN TESTS] ...

Compile & install 64bit Panda Linux

Note: If you decide not to use any arguments, the previously set values will
be used by default.

    -b          Whether to create backup. Defaults to FALSE.
                    TRUE    - Create
                    FALSE   - Skip

    -h          Display this help and exit

    -i          Sets the installation directory.

    -j          Run concurrent jobs. Defaults to value in nproc.
                    0       - Uses all cores
                    1-      - Any number onwards 1 no. of core(s) will be used

    -r          Resets options to their default value

    -t          Whether to run all the tests. Defaults to TRUE.
                    TRUE    - Run
                    FALSE   - Don't run

EOF
}

# Parse options
while getopts ":t:j:i:hb:rm:" opt; do
    case ${opt} in

        b )
            if [ ${OPTARG} = TRUE ] || [ ${OPTARG} = FALSE ]; then
                sed -i "s#.*DO_BACKUP=.*#DO_BACKUP=${OPTARG}#" variables.sh
                sed -i "s#.*DO_BACKUP=.*#export DO_BACKUP=${OPTARG}#" ~/.bashrc
            else
                echo error "Invalid argument. -b only takes either 'TRUE' or 'FALSE'."
                exit 1
            fi
            ;;

        h )
            show_help;
            exit 1
            ;;

        i )
            # Validate path provided by the user
            # Make sure a filesystem is mounted on this provided path
            if [ "$(cat /proc/mounts | grep -w ${OPTARG} | cut -d" " -f1)" ]; then
                sed -i "s#.*INSTALL_DIR=.*#INSTALL_DIR=${OPTARG}#" variables.sh
                sed -i "s#.*DONE_DIR=.*#DONE_DIR=${OPTARG}/done#" variables.sh
                sed -i "s#.*LOGS_DIR=.*#LOGS_DIR=${OPTARG}/logs#" variables.sh

                sed -i "s#.*INSTALL_DIR=.*#export INSTALL_DIR=${OPTARG}#" ~/.bashrc
                sed -i "s#.*DONE_DIR=.*#export DONE_DIR=${OPTARG}/done#" ~/.bashrc
                sed -i "s#.*LOGS_DIR=.*#export LOGS_DIR=${OPTARG}/logs#" ~/.bashrc
			else
				echo empty
				echo error "Invalid installation path."
				echo error "Please read the documentation properly and fix the errors!"
				echo empty
				exit 1
            fi
            ;;

        j )
            if [ ${OPTARG} -eq 0 ]; then
                sed -i "s#.*MAKE_PARALLEL=.*#MAKE_PARALLEL=-j$(cat /proc/cpuinfo | grep processor | wc -l)#" variables.sh
                sed -i "s#.*MAKE_PARALLEL=.*#export MAKE_PARALLEL=-j$(cat /proc/cpuinfo | grep processor | wc -l)#" ~/.bashrc
            else
                sed -i "s#.*MAKE_PARALLEL=.*#MAKE_PARALLEL=-j${OPTARG}#" variables.sh
                sed -i "s#.*MAKE_PARALLEL=.*#export MAKE_PARALLEL=-j${OPTARG}#" ~/.bashrc
            fi
            ;;

        r )
            sed -i "s#.*DO_BACKUP=.*#DO_BACKUP=TRUE#" variables.sh
            sed -i "s#.*INSTALL_DIR=.*#INSTALL_DIR=/tmp/panda64#" variables.sh
            sed -i "s#.*MAKE_PARALLEL=.*#MAKE_PARALLEL=-j$(cat /proc/cpuinfo | grep processor | wc -l)#" variables.sh
            sed -i "s#.*MAKE_TESTS=.*#MAKE_TESTS=TRUE#" variables.sh
            sed -i "s#.*DONE_DIR=.*#DONE_DIR=/tmp/panda64/done#" variables.sh
            sed -i "s#.*LOGS_DIR=.*#LOGS_DIR=/tmp/panda64/logs#" variables.sh

            sed -i "s#.*DO_BACKUP=.*#export DO_BACKUP=TRUE#" ~/.bashrc
            sed -i "s#.*INSTALL_DIR=.*#export INSTALL_DIR=/tmp/panda64#" ~/.bashrc
            sed -i "s#.*MAKE_PARALLEL=.*#export MAKE_PARALLEL=-j$(cat /proc/cpuinfo | grep processor | wc -l)#" ~/.bashrc
            sed -i "s#.*MAKE_TESTS=.*#export MAKE_TESTS=TRUE#" ~/.bashrc
            sed -i "s#.*DONE_DIR=.*#export DONE_DIR=/tmp/panda64/done#" ~/.bashrc
            sed -i "s#.*LOGS_DIR=.*#export LOGS_DIR=/tmp/panda64/logs#" ~/.bashrc
            ;;

        t )
            if [ ${OPTARG} = TRUE ] || [ ${OPTARG} = FALSE ]; then
                sed -i "s#.*MAKE_TESTS=.*#MAKE_TESTS=${OPTARG}#" variables.sh
                sed -i "s#.*MAKE_TESTS=.*#export MAKE_TESTS=${OPTARG}#" ~/.bashrc
            else
                echo error "Invalid argument. -t only takes either 'TRUE' or 'FALSE'."
                exit 1
            fi
            ;;

        \? )
            echo error "Invalid option: -{$OPTARG}" >&2
            exit 1
            ;;

        : )
            echo error "Option -${OPTARG} requires an argument."
            exit 1
            ;;
    esac
done

source variables.sh
source ~/.bashrc
# Show installation configuration information to the user
echo empty
echo warn "General Installation Configuration"
echo norm "${BOLD}Installation Directory:${NORM}    ${INSTALL_DIR}"
echo norm "${BOLD}Do backup:${NORM}                 ${DO_BACKUP}"
echo norm "${BOLD}Run tests:${NORM}                 ${MAKE_TESTS}"
echo norm "${BOLD}No. of jobs:${NORM}               ${MAKE_PARALLEL}"
echo norm "${BOLD}Host:${NORM}                      ${PANDA_HOST}"
echo norm "${BOLD}Target:${NORM}                    ${TARGET}"
echo norm "${BOLD}Path:${NORM}                      ${PATH}"
echo empty
echo norm "${BOLD}Tools Directory:${NORM}           /tools"
echo empty
echo norm "${BOLD}Done Directory:${NORM}            ${DONE_DIR}"
echo norm "${BOLD}Logs Directory:${NORM}            ${LOGS_DIR}"
echo empty

# Validate path provided by the user
# Make sure a filesystem is mounted on the path provided
if [ ! "$(cat /proc/mounts | grep -w ${INSTALL_DIR} | cut -d' ' -f1)" ]; then
	echo empty
	echo error "Invalid installation path."
	echo error "Please read the documentation properly and fix the errors!"
	echo empty
	exit 1
elif [ "$(df --output=target,size ${INSTALL_DIR} | awk ' NR==2 { print $2 } ')" -lt ${MIN_SPACE_REQ} ]; then
	echo empty
	echo error "Minimum 6GB is required to continue!"
	echo empty
	exit 1
fi

askConfirm;

if [ ! -d ${INSTALL_DIR}/dev ]; then
	# Get ${INSTALL_DIR} permissions
	requireRoot chown -R `whoami` ${INSTALL_DIR}
    # Create necessary directories and symlinks
    echo warn "Creating necessary folders..."
    
    if [ $(readlink /tools) ]; then
        requireRoot rm /tools
    fi
    
    install -d ${INSTALL_DIR}/tools
    install -d ${LOGS_DIR}
    install -d ${DONE_DIR}    

    requireRoot ln -s ${INSTALL_DIR}/tools /
fi

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N                                  #
#----------------------------------------------------------------------------------------------------#

if [ ! -f ${INSTALL_DIR}/.done ]; then
	echo empty
	echo success "Starting installation..."
	echo empty

	# Copying data to the installation location
	echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
	cp -ur ./* ${INSTALL_DIR}

	# Constructing temporary system
	pushd ${TEMP_SYSTEM_DIR} && bash init.sh && popd

	# Test to boot or to chroot
	testBootOrChroot;

	# Building the actual system
	pushd ${BUILD_SYSTEM_DIR} && bash init.sh && popd

	# Configuring the system
	pushd ${CONFIGURE_SYSTEM_DIR} && bash init.sh && popd

	# Finalize the system
	pushd ${FINALIZE_SYSTEM_DIR} && bash init.sh && popd

else
	echo success "Installation Finished!"
	echo empty
fi

# Creates backup of the system if -b is TRUE
createBackup;
