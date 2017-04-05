#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

echo "Installing EPICS V4"

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

USER=$(whoami)
TOP_DIR=$(pwd)
EPICS_ENV_DIR=/etc/profile.d
LDCONF_DIR=/etc/ld.so.conf.d
EPICS_EXTENSIONS_SRC=${EPICS_EXTENSIONS}/src

# Install EPICS base and used modules

# Source repo versions
. ./repo-versions.sh

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc https://downloads.sourceforge.net/project/epics-pvdata/${EPICS_V4_BASE_VERSION}/EPICS-CPP-${EPICS_V4_BASE_VERSION}.tar.gz
fi

############################## EPICS Base #####################################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS V4 per user request (-i flag not set)"
    exit 0
fi

# Prepare environment
sudo mkdir -p ${EPICS_FOLDER}
sudo chmod 755 ${EPICS_FOLDER}
sudo chown ${USER}:${USER} ${EPICS_FOLDER}

# Extract and install EPICS
cd ${EPICS_FOLDER}
tar xvzf ${TOP_DIR}/EPICS-CPP-${EPICS_V4_BASE_VERSION}.tar.gz

# Change to EPICS v4 folder
EPICS_V4_CPP=${EPICS_FOLDER}/EPICS-CPP-${EPICS_V4_BASE_VERSION}
cd ${EPICS_V4_CPP}

# Remove possible existing symlink
rm -f ${EPICS_V4}
# Create symlink
ln -sf ${EPICS_V4_CPP} ${EPICS_V4}

# Update ldconfig with EPICS libs
for path in normativeTypesCPP pvaClientCPP pvaSrv pvDatabaseCPP pvAccessCPP \
    pvaPy pvCommonCPP pvDataCPP; do
    echo "${EPICS_V4_CPP}/${path}/${EPICS_HOST_ARCH}/lib" | \
        sudo tee -a /etc/ld.so.conf.d/epics.conf
done

# Update ldconfig cache
sudo ldconfig

# Compile EPICS base
make EPICS_BASE=${EPICS_BASE}
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

echo "EPICS V4 installation successfully completed"
