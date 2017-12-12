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

# Only install new IOC stats if we are using epics base
# 3.14.12.6 + synApps_R5_8
if [ "${EPICS_BASE_VERSION}" != "3.14.12.6" ] || [ "${SYNAPPS_VERSION}" != "5_8" ]; then
    echo "Not installing IOCStats new version, using synApps one"
    exit 0
fi

echo "Installing IOC Stats"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
IOC_STATS_PATH="${EPICS_FOLDER}/iocStats"

cd "${EPICS_FOLDER}"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    git clone https://github.com/epics-modules/iocStats iocStats
fi

########################### EPICS IOC Stats module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS IOCStats per user request (-i flag not set)"
    exit 0
fi

if [ "${INSTALL_APP}" == "yes" ] && [ ! -d "iocStats" ]; then
    echo "IOC Stats files are not available on ${IOC_STATS_PATH}" >&2
    exit 1
fi

cd iocStats
git checkout 3.1.15

# Set EPICS variables in devIOCStats configure/RELEASE
sed -i -e "
    s|^SNCSEQ = .*|SNCSEQ = ${EPICS_SYNAPPS}/seq-2-2-1|g; \
    s|^EPICS_BASE=.*|EPICS_BASE = ${EPICS_BASE}|g; \
" configure/RELEASE
cd ..

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^DEVIOCSTATS=.*|DEVIOCSTATS=${IOC_STATS_PATH}|" configure/RELEASE

# As this should be executed before installing synapps,
# don't try to "make" synapps and instead just exits
