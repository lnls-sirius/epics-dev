#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

./get-synapps-deps.sh

echo "Installing SynApps LNLS"

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

USER=$(whoami)
TOP_DIR=$(pwd)
EPICS_ENV_DIR=/etc/profile.d

# Source repo versions
. ./repo-versions.sh

EPICS_SYNAPPS_LNLS_PATH="${EPICS_FOLDER}/synApps-lnls-${SYNAPPS_LNLS_VERSION_TR}"
EPICS_SYNAPPS_LNLS="${EPICS_SYNAPPS_LNLS_PATH}/support"
EPICS_SYNAPPS_LNLS_TAR="synApps-lnls-${SYNAPPS_LNLS_VERSION_TR}.tar.gz"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget --no-check-certificate -nc -O ${EPICS_SYNAPPS_LNLS_TAR} \
        https://github.com/lnls-dig/support/releases/download/${SYNAPPS_LNLS_VERSION_TR}/synApps-lnls-${SYNAPPS_LNLS_VERSION_TR}.tar.gz || \
        true
fi

########################### EPICS synApps modules ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS SynApps per user request (-i flag not set)"
    exit 0
fi

cd ${EPICS_FOLDER}
tar xvzf ${TOP_DIR}/${EPICS_SYNAPPS_LNLS_TAR}

cd ${EPICS_SYNAPPS_LNLS}

# Fix paths
sed -i -e "s|SUPPORT=.*|SUPPORT=${EPICS_SYNAPPS_LNLS}|g" \
    -e "s|EPICS_BASE=.*|EPICS_BASE=${EPICS_BASE}|g" configure/RELEASE

# Fix ADCore paths
sed -i \
    -e "s|HDF5\( *\)=.*|HDF5\1= ${HDF5_BASE}|g" \
    -e "s|HDF5_LIB\( *\)=.*|HDF5_LIB\1= ${HDF5_LIB}|g" \
    -e "s|HDF5_INCLUDE\( *\)=.*|HDF5_INCLUDE\1= -I${HDF5_INCLUDE}|g" \
    -e "s|SZIP\( *\)=.*|SZIP\1= ${SZIP_BASE}|g" \
    -e "s|SZIP_LIB\( *\)=.*|SZIP_LIB\1= ${SZIP_LIB}|g" \
    -e "s|SZIP_INCLUDE\( *\)=.*|SZIP_INCLUDE\1= -I${SZIP_INCLUDE}|g" \
    -e "s|GRAPHICS_MAGICK\( *\)=.*|GRAPHICS_MAGICK\1= ${GRAPHICS_MAGICK_BASE}|g" \
    -e "s|GRAPHICS_MAGICK_LIB\( *\)=.*|GRAPHICS_MAGICK_LIB\1= ${GRAPHICS_MAGICK_LIB}|g" \
    -e "s|GRAPHICS_MAGICK_INCLUDE\( *\)=.*|GRAPHICS_MAGICK_INCLUDE\1= -I${GRAPHICS_MAGICK_INCLUDE}|g" \
    areaDetector-*/configure/CONFIG_SITE.local.linux-x86_64

# Debug/Info stuff
echo "======= configure/RELEASE.local ========================================="
cat configure/RELEASE.local || /bin/true

echo "======= configure/RELEASE ==============================================="
cat configure/RELEASE

echo "======= configure/CONFIG_SITE.linux-x86_64.Common ======================="
cat configure/CONFIG_SITE.linux-x86_64.Common || /bin/true

make release

# Build synapps

make
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/${EPICS_SYNAPPS_LNLS_TAR}
fi

echo "SynApps LNLS installation successfully completed"
