#!/usr/bin/env bash

shopt -s -o pipefail
set -e

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: This will make sure each user is set up appropriately with the correct group memberships, as well"
    echo -e "as copy the appropriate template of files from /etc/skel to each new user's home directory."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function build() {
	# Modify the /etc/default/useradd that shadow installed
	useradd -D -b /home
	sed -i "/CREATE_MAIL_SPOOL/s/yes/no/" /etc/default/useradd

	# Complete the EXPIRE and SHELL entries of /etc/default/useradd based on the current environment
	/usr/sbin/useradd -D -s/bin/bash

	# Create the /etc/skel directory
	mkdir -pv /etc/skel

	# Create the adduser script and give it executable permissions
	cat > /usr/sbin/adduser << "EOF"
#!/bin/sh
useradd -m $1
passwd $1
gpasswd -a $1 users
gpasswd -a $1 audio
EOF
	chmod +x /usr/sbin/adduser
}

# Run the installation procedure
time { showHelp;build; }
# Verify installation
if [ -d /etc/profile.d ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi