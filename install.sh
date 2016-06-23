#!/usr/bin/env bash

set -e # Exit upon error

# This script generates a 64-bit system
source variables.sh
source functions.sh

# This script should only be executed by $PANDA_USER
verify-user;

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

    -c          Copies the system to the final destination

    -h          Display this help and exit

    -i          Sets the installation directory. Make sure you have read/write
                access for the directory. Best option is to use /tmp/xxx as
                /tmp provides read/write permissions by default to all the users.
                eg /tmp/panda

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
while getopts ":t:j:i:hb:rc:" opt; do
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

		c)
			sed -i "s#.*COPY_DIR=.*#COPY_DIR=${OPTARG}#" variables.sh
			;;

        h )
            show_help;
            exit 1
            ;;

        i )
            sed -i "s#.*INSTALL_DIR=.*#INSTALL_DIR=${OPTARG}#" variables.sh
            sed -i "s#.*TOOLS_DIR=.*#TOOLS_DIR=${OPTARG}/tools#" variables.sh
            sed -i "s#.*CROSS_DIR=.*#CROSS_DIR=${OPTARG}/cross-tools#" variables.sh
            sed -i "s#.*PATH=.*#PATH=${HOST_CDIR}/bin:/bin:/usr/bin#" variables.sh

            sed -i "s#.*INSTALL_DIR=.*#export INSTALL_DIR=${OPTARG}#" ~/.bashrc
            sed -i "s#.*TOOLS_DIR=.*#export TOOLS_DIR=${OPTARG}/tools#" ~/.bashrc
            sed -i "s#.*CROSS_DIR=.*#export CROSS_DIR=${OPTARG}/cross-tools#" ~/.bashrc
            sed -i "s#.*PATH=.*#export PATH=${HOST_CDIR}/bin:/bin:/usr/bin#" ~/.bashrc
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
            sed -i "s#.*TOOLS_DIR=.*#TOOLS_DIR=${INSTALL_DIR}/tools#" variables.sh
            sed -i "s#.*CROSS_DIR=.*#CROSS_DIR=${INSTALL_DIR}/cross-tools#" variables.sh
            sed -i "s#.*PATH=.*#PATH=${HOST_CDIR}/bin:/bin:/usr/bin#" variables.sh

            sed -i "s#.*DO_BACKUP=.*#export DO_BACKUP=TRUE#" ~/.bashrc
            sed -i "s#.*INSTALL_DIR=.*#export INSTALL_DIR=/tmp/panda64#" ~/.bashrc
            sed -i "s#.*MAKE_PARALLEL=.*#export MAKE_PARALLEL=-j$(cat /proc/cpuinfo | grep processor | wc -l)#" ~/.bashrc
            sed -i "s#.*MAKE_TESTS=.*#export MAKE_TESTS=TRUE#" ~/.bashrc
            sed -i "s#.*TOOLS_DIR=.*#export TOOLS_DIR=${INSTALL_DIR}/tools#" ~/.bashrc
            sed -i "s#.*CROSS_DIR=.*#export CROSS_DIR=${INSTALL_DIR}/cross-tools#" ~/.bashrc
            sed -i "s#.*PATH=.*#export PATH=${HOST_CDIR}/bin:/bin:/usr/bin#" ~/.bashrc
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
echo warn "General Installation Configuration"
echo norm "${BOLD}Installation Directory:${NORM}    ${INSTALL_DIR}"
echo norm "${BOLD}Do backup:${NORM}                 ${DO_BACKUP}"
echo norm "${BOLD}Run tests:${NORM}                 ${MAKE_TESTS}"
echo norm "${BOLD}No. of jobs:${NORM}               ${MAKE_PARALLEL}"
echo norm "${BOLD}Host:${NORM}                      ${PANDA_HOST}"
echo norm "${BOLD}Target:${NORM}                    ${TARGET}"
echo norm "${BOLD}Path:${NORM}                      ${PATH}"
echo empty
echo norm "${BOLD}Tools Directory:${NORM}           ${TOOLS_DIR}"
echo norm "${BOLD}Cross Directory:${NORM}           ${CROSS_DIR}"
echo empty

askConfirm;

# Check installation directory existence
if [ ! -d ${INSTALL_DIR} ]; then
    # Create installation folder
    echo warn "Creating ${INSTALL_DIR} folder..."
    mkdir -p ${INSTALL_DIR}
    echo empty
fi

if [ ! -d ${INSTALL_DIR}/dev ]; then
    # Create necessary directories and symlinks
    echo warn "Creating necessary folders..."
    install -d ${TOOLS_DIR}
    install -d ${CROSS_DIR}
    install -d ${LOGS_DIR}
    install -d ${DONE_DIR}

    if [ $(readlink ${HOST_TDIR}) ] && [ $(readlink ${HOST_CDIR}) ]; then
        requireRoot rm ${HOST_TDIR} ${HOST_CDIR}
    fi

    requireRoot ln -s ${TOOLS_DIR} /
    requireRoot ln -s ${CROSS_DIR} /
fi

#----------------------------------------------------------------------------------------------------#
#                               S T A R T   I N S T A L L A T I O N                                  #
#----------------------------------------------------------------------------------------------------#

if [ ! -f ${DONE_DIR}/finalize-system/lsb ]; then
	echo empty
	echo success "Starting installation..."
	echo empty

	# Copying data to the installation location
	echo warn "Copying data to ${INSTALL_DIR}. Please wait..."
	cp -ur ./* ${INSTALL_DIR}
	echo empty

	echo warn "Building Cross compile tools..."
	pushd ${CROSS_COMPILE_DIR} && bash init.sh && popd

	echo empty
	echo warn "Constructing temporary system..."
	pushd ${TEMP_SYSTEM_DIR} && bash init.sh && popd

	echo empty
	echo warn "Building the actual system..."
	pushd ${BUILD_SYSTEM_DIR} && bash init.sh && popd

	echo empty
	echo warn "Configuring the system..."
	pushd ${CONFIGURE_SYSTEM_DIR} && bash init.sh && popd

	echo empty
	echo warn "Finalize the system..."
	pushd ${FINALIZE_SYSTEM_DIR} && bash init.sh && popd
fi

if [ -f ${DONE_DIR}/finalize-system/lsb ]; then
	echo empty
	echo warn "Cleaning the system..."

	requireRoot rm -rf ${INSTALL_DIR}/{build-system,configure-system,cross-compile-tools,docs,finalize-system,patches,sources,temp-system}
	requireRoot rm -rf ${INSTALL_DIR}/{*.md,*.git*,*.sh,wget-list}
	requireRoot rm -rf ${TOOLS_DIR} ${HOST_TDIR}
	requireRoot rm -rf ${CROSS_DIR} ${HOST_CDIR}
	checkCommand;

	# Copy the files to the final destination
	if [ ${COPY_DIR} != null ]; then
		# Make sure the destination directory is empty
		if [ ! "$(ls -A ${COPY_DIR})" ]; then
			requireRoot cp -rfp ${INSTALL_DIR}/* ${COPY_DIR}
			requireRoot rm -rf ${COPY_DIR}/{done,logs}
		else
			echo error "${COPY_DIR} is not empty. Please select another directory!"
			exit 1
		fi
	fi
fi

# Creates backup of the system if -b is TRUE
createBackup;