#!/bin/bash

source variables.sh
source functions.sh

# Setups up the user if not already done
function install-user() {
    if [ ! $(cat /etc/passwd | grep ${PANDA_USER}) ]; then
        echo warn "Creating user ${PANDA_USER}..."
        requireRoot groupadd "${PANDA_GROUP}"
        requireRoot useradd -s /bin/bash -g "${PANDA_GROUP}" -d "/home/${PANDA_HOME}" "${PANDA_USER}"
        requireRoot mkdir -p "/home/${PANDA_HOME}"
        echo empty
        requireRoot passwd "${PANDA_USER}"
        requireRoot usermod -aG sudo "${PANDA_USER}"
        echo success "User successfully setup!"
        echo empty
    fi

    # Copy all data to ${PANDA_HOME}
    echo warn "Moving data to '/home/${PANDA_HOME}'"
    requireRoot cp -rfu ./* "/home/${PANDA_HOME}"
    requireRoot chown -R ${PANDA_USER}:${PANDA_GROUP} /home/${PANDA_HOME}
    echo empty
}