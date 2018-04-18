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
    echo "Not installing CaputRecorder new version, as EPICS_BASE_VERSION is less than 3.14. Using SynApps one"
    exit 0
fi

echo "Installing CaputRecorder"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
CAPUT_RECORDER_PATH="${EPICS_FOLDER}/caputRecorder-${CAPUT_RECORDER_VERSION}"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc -O ${CAPUT_RECORDER_VERSION}.tar.gz \
        https://github.com/epics-modules/caputRecorder/archive/${CAPUT_RECORDER_VERSION_RELEASE}.tar.gz || \
        true
fi

########################### EPICS IOC Stats module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS CaputRecorder per user request (-i flag not set)"
    exit 0
fi

# Tell environment that you're being installed
export CAPUT_RECORDER_NO_SYNAPPS=yes

mkdir -p "${CAPUT_RECORDER_PATH}"
cd "${CAPUT_RECORDER_PATH}"

tar xvzf ${TOP_DIR}/${CAPUT_RECORDER_VERSION}.tar.gz
mv caputRecorder-*/* .
rm -rf caputRecorder-*

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
