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
    echo "Not installing Calc new version, as EPICS_BASE_VERSION is less than 3.14. Using SynApps one"
    exit 0
fi

echo "Installing Calc"

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
CALC_PATH="${EPICS_FOLDER}/calc-${CALC_VERSION_TR}"
CALC_TAR="calc-${CALC_VERSION_TR}.tar.gz"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc -O ${CALC_TAR} \
        https://github.com/epics-modules/calc/archive/${CALC_VERSION_RELEASE}.tar.gz || \
        true
fi

########################### EPICS Calc module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS Calc per user request (-i flag not set)"
    exit 0
fi

# Tell environment that you're being installed
export CALC_NO_SYNAPPS=yes

mkdir -p "${CALC_PATH}"
cd "${CALC_PATH}"

tar xvzf ${TOP_DIR}/${CALC_TAR}
mv calc-*/* .
rm -rf calc-*

# Set EPICS variables in Calc configure/RELEASE
sed -i -e "
    s|^EPICS_BASE=.*|EPICS_BASE = ${EPICS_BASE}|g; \
    s|^SUPPORT *=.*|SUPPORT=${EPICS_SYNAPPS}|g; \
    s|^SNCSEQ *=.*|SNCSEQ=${EPICS_FOLDER}/seq|g; \
    s|^SSCAN *=\(.*\)|#SSCAN=\1|g; \
" configure/RELEASE
cd ..

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/${CALC_TAR}
fi

######################## Fix SynApps and rebuild #############################

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^CALC *=.*|CALC=${CALC_PATH}|" configure/RELEASE

# Replace every RELEASE file with new Calc
sed -i -e "s|^CALC *=.*|CALC=${CALC_PATH}|" \
    measComp-1-1/configure/RELEASE \
    delaygen-1-1-1/configure/RELEASE \
    dxp-3-4/configure/RELEASE \
    optics-2-9-3/configure/RELEASE \
    quadEM-5-0/configure/RELEASE \
    areaDetector-R2-0/configure/RELEASE \
    mca-7-6/configure/RELEASE \
    camac-2-7/configure/RELEASE \
    stream-2-6a/configure/RELEASE


# As this should be executed before installing synapps,
# don't try to "make" synapps and instead just exits
