#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

./get-synapps-deps.sh

echo "Installing SynApps"

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

USER=$(whoami)
TOP_DIR=$(pwd)
EPICS_ENV_DIR=/etc/profile.d

# Source repo versions
. ./repo-versions.sh

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget --no-check-certificate -nc https://www.aps.anl.gov/files/APS-Uploads/BCDA/synApps/tar/synApps_${SYNAPPS_VERSION}.tar.gz
    # Run IOC Stats script here only for download. For installation it will run
    # after SynApps "make release" command
    DOWNLOAD_APP=yes INSTALL_APP=no CLEANUP_APP=no ./get-ioc-stats.sh
    DOWNLOAD_APP=yes INSTALL_APP=no CLEANUP_APP=no ./get-caput-recorder.sh
fi

########################### EPICS synApps modules ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS SynApps per user request (-i flag not set)"
    exit 0
fi

cd ${EPICS_FOLDER}
tar xvzf ${TOP_DIR}/synApps_${SYNAPPS_VERSION}.tar.gz

cd ${EPICS_SYNAPPS}

# Fix paths
sed -i -e "s|SUPPORT=.*|SUPPORT=${EPICS_SYNAPPS}|g" \
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
    areaDetector-R2-0/configure/CONFIG_SITE.local.linux-x86_64

# Change some modules to dynamic link to libhdf5 and libsz.
# For some reason, we don't have the static versions of them
# and the compilation fails with:
# /bin/ld: cannot find -lhdf5
# /bin/ld: cannot find -lsz
sed -i \
    -e "s|STATIC_BUILD=YES|STATIC_BUILD=NO|g" \
    quadEM-5-0/configure/CONFIG_SITE

sed -i \
    -e "s|STATIC_BUILD=YES|STATIC_BUILD=NO|g" \
    dxp-3-4/configure/CONFIG_SITE

# EPICS synApps R5_8 does not search hdf5 headers in /usr/include/hdf5/serial,
# which is where Ubuntu 16.04 installs them. Symlink them to /usr/include
sudo ln -sf /usr/include/hdf5/serial/*.h /usr/include/ || /bin/true
# Create symlinks so linker can find it
sudo ln -sf ${SZIP_LIB}/libsz.so.2 ${SZIP_LIB}/libsz.so || /bin/true

# Debug/Info stuff
echo "======= configure/RELEASE.local ========================================="
cat configure/RELEASE.local || /bin/true

echo "======= configure/RELEASE ==============================================="
cat configure/RELEASE

echo "======= configure/CONFIG_SITE.linux-x86_64.Common ======================="
cat configure/CONFIG_SITE.linux-x86_64.Common || /bin/true

make release

# Patch SynApps modules before building synApps
cd ${TOP_DIR}
./get-ioc-stats.sh
cd ${EPICS_SYNAPPS}

make
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/synApps_${SYNAPPS_VERSION}.tar.gz
fi

echo "SynApps installation successfully completed"
