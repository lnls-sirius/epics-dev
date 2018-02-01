#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

echo "Installing CA Gateway"

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

TOP_DIR="$(pwd)"

# Source repo versions
. ./repo-versions.sh

CA_GATEWAY_PATH="${CA_GATEWAY_PATH:-${EPICS_FOLDER}/ca-gateway}"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc https://github.com/epics-extensions/ca-gateway/archive/${CA_GATEWAY_VERSION}.tar.gz
fi

tar -xvzf ${TOP_DIR}/${CA_GATEWAY_VERSION}.tar.gz

mv ${TOP_DIR}/ca-gateway-${CA_GATEWAY_VERSION} ${CA_GATEWAY_PATH}

cd ${CA_GATEWAY_PATH}

sed -i "s:#EPICS_BASE=.*:EPICS_BASE=${EPICS_BASE}:" ${CA_GATEWAY_PATH}/configure/RELEASE

make

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/${CA_GATEWAY_VERSION}.tar.gz
fi
