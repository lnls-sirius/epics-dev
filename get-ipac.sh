#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e
# Be verbose
set -x

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

USER="$(whoami)"
TOP_DIR="$(pwd)"

# Source repo versions
. ./repo-versions.sh

# Install new version if EPICS is recent enough
EPICS_BASE_RELMAJ=${EPICS_BASE_RELEASE}.${EPICS_BASE_MAJOR}
if [ "${EPICS_BASE_VERSION}" \< "3.14" ]; then
    echo "Not installing IPAC new version, as EPICS_BASE_VERSION is less than 3.14. Using SynApps one"
    exit 0
fi

echo "Installing IPAC"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
IPAC_PATH="${EPICS_FOLDER}/ipac-${IPAC_VERSION}"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc https://github.com/epics-modules/ipac/releases/download/${IPAC_VERSION}/ipac-${IPAC_VERSION}.tar.gz
fi

########################### EPICS IPAC module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS IPAC per user request (-i flag not set)"
    exit 0
fi

# Tell environment that you're being installed
export IPAC_NO_SYNAPPS=yes

mkdir -p "${IPAC_PATH}"
cd "${IPAC_PATH}"

tar xvzf ${TOP_DIR}/ipac-${IPAC_VERSION}.tar.gz
mv ipac-${IPAC_VERSION}/* .
rm -rf ipac-${IPAC_VERSION}

# Set EPICS variables in IPAC configure/RELEASE
sed -i -e "
    s|^EPICS_BASE=.*|EPICS_BASE = ${EPICS_BASE}|g; \
" configure/RELEASE
cd ..

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/ipac-${IPAC_VERSION}.tar.gz
fi

######################## Fix SynApps and rebuild #############################

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^IPAC *=.*|IPAC=${IPAC_PATH}|" configure/RELEASE

# Replace every RELEASE file with new IPAC
sed -i -e "s|^IPAC *=.*|IPAC=${IPAC_PATH}|" \
    ip-2-17/iocs/ipExample/configure/RELEASE \
    ip-2-17/configure/RELEASE \
    vac-1-5-1/configure/RELEASE \
    motor-6-9/configure/RELEASE \
    delaygen-1-1-1/configure/RELEASE \
    ip330-2-8/configure/RELEASE \
    love-3-2-5/configure/RELEASE \
    softGlue-2-4-3/configure/RELEASE \
    quadEM-5-0/configure/RELEASE \
    asyn-4-26/configure/RELEASE \
    ipUnidig-2-10/configure/RELEASE \
    dac128V-2-8/configure/RELEASE

# As this should be executed before installing synapps,
# don't try to "make" synapps and instead just exits
