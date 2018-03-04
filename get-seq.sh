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

# Install new version if EPICS is recent enough
EPICS_BASE_RELMAJ=${EPICS_BASE_RELEASE}.${EPICS_BASE_MAJOR}
if [ "${EPICS_BASE_VERSION}" \< "3.14" ]; then
    echo "Not installing Sequencer new version, as EPICS_BASE_VERSION is less than 3.16. Using SynApps one"
    exit 0
fi

echo "Installing Sequencer"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
SEQ_PATH="${EPICS_FOLDER}/seq"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc http://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${SEQ_VERSION}.tar.gz
fi

########################### EPICS Sequencer module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS Sequencer per user request (-i flag not set)"
    exit 0
fi

# Tell environment that you're being installed
export SEQ_NO_SYNAPPS=yes

mkdir -p "${SEQ_PATH}"
cd "${SEQ_PATH}"

tar xvzf ${TOP_DIR}/seq-${SEQ_VERSION}.tar.gz
mv seq-${SEQ_VERSION}/* .
rm -rf seq-${SEQ_VERSION}

# Set EPICS variables in Sequencer configure/RELEASE
sed -i -e "
    s|^EPICS_BASE=.*|EPICS_BASE = ${EPICS_BASE}|g; \
" configure/RELEASE
cd ..

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/seq-${SEQ_VERSION}.tar.gz
fi

######################## Fix SynApps and rebuild #############################

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^SNCSEQ=.*|SNCSEQ=${SEQ_PATH}|" configure/RELEASE

# As this should be executed before installing synapps,
# don't try to "make" synapps and instead just exits