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
    echo "Not installing IOCStats new version, as EPICS_BASE_VERSION is less than 3.14. Using SynApps one"
    exit 0
fi

echo "Installing IOC Stats"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
IOC_STATS_PATH="${EPICS_FOLDER}/iocStats"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc https://github.com/epics-modules/iocStats/archive/${IOC_STATS_VERSION}.tar.gz
fi

########################### EPICS IOC Stats module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS IOCStats per user request (-i flag not set)"
    exit 0
fi

# Tell environment that you're being installed
export IOC_STATS_NO_SYNAPPS=yes

mkdir -p "${IOC_STATS_PATH}"
cd "${IOC_STATS_PATH}"

tar xvzf ${TOP_DIR}/${IOC_STATS_VERSION}.tar.gz
mv iocStats-${IOC_STATS_VERSION}/* .
rm -rf iocStats-${IOC_STATS_VERSION}

# Set EPICS variables in devIOCStats configure/RELEASE
sed -i -e "
    s|^SNCSEQ = .*|SNCSEQ = ${EPICS_FOLDER}/seq|g; \
    s|^EPICS_BASE=.*|EPICS_BASE = ${EPICS_BASE}|g; \
" configure/RELEASE
cd ..

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/${IOC_STATS_VERSION}.tar.gz
fi

######################## Fix SynApps and rebuild #############################

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^DEVIOCSTATS=.*|DEVIOCSTATS=${IOC_STATS_PATH}|" configure/RELEASE

# As this should be executed before installing synapps,
# don't try to "make" synapps and instead just exits
