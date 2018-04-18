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
    echo "Not installing Autosave new version, as EPICS_BASE_VERSION is less than 3.14. Using SynApps one"
    exit 0
fi

echo "Installing Autosave"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
AUTOSAVE_PATH="${EPICS_FOLDER}/autosave-${AUTOSAVE_VERSION}"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc -O ${AUTOSAVE_VERSION}.tar.gz \
        https://github.com/epics-modules/autosave/archive/${AUTOSAVE_VERSION_RELEASE}.tar.gz || \
        true
fi

########################### EPICS Autosave module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS Autosave per user request (-i flag not set)"
    exit 0
fi

# Tell environment that you're being installed
export AUTOSAVE_NO_SYNAPPS=yes

mkdir -p "${AUTOSAVE_PATH}"
cd "${AUTOSAVE_PATH}"

tar xvzf ${TOP_DIR}/${AUTOSAVE_VERSION}.tar.gz
mv autosave-*/* .
rm -rf autosave-*

# Set EPICS variables in Autosave configure/RELEASE
sed -i -e "
    s|^EPICS_BASE=.*|EPICS_BASE = ${EPICS_BASE}|g; \
" configure/RELEASE
cd ..

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/autosave-${AUTOSAVE_VERSION}.tar.gz
fi

######################## Fix SynApps and rebuild #############################

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^AUTOSAVE *=.*|AUTOSAVE=${AUTOSAVE_PATH}|" configure/RELEASE

# Replace every RELEASE file with new Autosave
sed -i -e "s|^AUTOSAVE *=.*|AUTOSAVE=${AUTOSAVE_PATH}|" \
    dxp-3-4/configure/RELEASE \
    delaygen-1-1-1/configure/RELEASE \
    mca-7-6/configure/RELEASE \
    areaDetector-R2-0/configure/RELEASE \
    measComp-1-1/configure/RELEASE \
    quadEM-5-0/configure/RELEASE

# As this should be executed before installing synapps,
# don't try to "make" synapps and instead just exits
