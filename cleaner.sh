#!/usr/bin/env bash

source variables.sh
source functions.sh

# Path of current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Remove the installation folders
echo warn "Removing installation files/folders..."
requireRoot rm -rf "${DIR}/build-system" "${DIR}/configure-system" "${DIR}/cross-compile-tools" "${DIR}/docs"   \
                   "${DIR}/finalize-system" "${DIR}/sources" "${DIR}/temp-system" "${DIR}/.git*" "${DIR}/*.md"  \
                   "${DIR}/wget-list" "${DIR}/.config" "${DIR}/tools" "${DIR}/cross-tools" "${HOST_TOOLS_DIR}"  \
                   "${HOST_CROSS_TOOLS_DIR}" "${DIR}/*.sh"
echo success "Finished!"
echo empty