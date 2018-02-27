#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

USER="$(whoami)"
TOP_DIR="$(pwd)"

# Source repo versions
. ./repo-versions.sh

EPICS_BASE_RELMAJ=${EPICS_BASE_RELEASE}.${EPICS_BASE_MAJOR}
# Only install new caput recorder for EPICS 3.15 forwards
if [ "${EPICS_BASE_RELMAJ}" \< "3.15" ]; then
    echo "Not installing CaputRecorder new version, as EPICS_BASE_VERSION is less than 3.15. Using SynApps one"
    exit 0
fi

echo "Installing CaputRecorder"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
CAPUT_RECORDER_PATH="${EPICS_FOLDER}/caputRecorder"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc https://github.com/epics-modules/caputRecorder/archive/${CAPUT_RECORDER_VERSION}.tar.gz
fi

########################### EPICS IOC Stats module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS CaputRecorder per user request (-i flag not set)"
    exit 0
fi

mkdir -p "${CAPUT_RECORDER_PATH}"
cd "${CAPUT_RECORDER_PATH}"

tar xvzf ${TOP_DIR}/${CAPUT_RECORDER_VERSION}.tar.gz
mv caputRecorder-${CAPUT_RECORDER_VERSION}/* .
rm -rf caputRecorder-${CAPUT_RECORDER_VERSION}

# Set EPICS variables in devIOCStats configure/RELEASE
sed -i -e "
    s|^EPICS_BASE=.*|EPICS_BASE = ${EPICS_BASE}|g; \
" configure/RELEASE
cd ..

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/${CAPUT_RECORDER_VERSION}.tar.gz
fi

######################## Fix SynApps and rebuild #############################

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^CAPUTRECORDER=.*|CAPUTRECORDER=${CAPUT_RECORDER_PATH}|" configure/RELEASE

# As this should be executed before installing synapps,
# don't try to "make" synapps and instead just exits
