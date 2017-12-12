#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

echo "Installing Stream Device"

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

USER="$(whoami)"
TOP_DIR="$(pwd)"

# Source repo versions
. ./repo-versions.sh

EPICS_SYNAPPS=${EPICS_FOLDER}/synApps_${SYNAPPS_VERSION}/support
STREAM_DEVICE_PATH="${EPICS_FOLDER}/stream"
STREAM_DEVICE_SRC_PATH="${STREAM_DEVICE_PATH}/streamDevice"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc https://github.com/paulscherrerinstitute/StreamDevice/archive/stream_${STREAM_DEVICE_VERSION}.tar.gz
fi

########################### EPICS Stream Device module ##############################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS StreamDevice per user request (-i flag not set)"
    exit 0
fi

mkdir -p "${STREAM_DEVICE_SRC_PATH}"
cd "${STREAM_DEVICE_SRC_PATH}"

tar xvzf ${TOP_DIR}/stream_${STREAM_DEVICE_VERSION}.tar.gz
mv StreamDevice-stream_${STREAM_DEVICE_VERSION}/* .
rm -rf StreamDevice-stream_${STREAM_DEVICE_VERSION}

# Go back and create EPICS build files
cd ${STREAM_DEVICE_PATH}
/opt/epics/base/bin/linux-x86_64/makeBaseApp.pl -t support -u "$USER" stream

# Add line "DIRS := $(DIRS) streamDevice/" after all lines that define DIRS
sed -i -e '
    /DIRS :=/ h;
    /DIRS :=/! {
        t reset_condition_flag;
        :reset_condition_flag;

        x;
        s/DIRS :=.*/DIRS := $(DIRS) streamDevice/;
        t replaced;
        b didnt_replace;

        :replaced;
        p;
        s/.*//;

        :didnt_replace;
        x;
    }' Makefile

# Set SUPPORT, ASYN, CALC and SSCAN variables in configure/RELEASE
sed -i -e "\
    /# *SNCSEQ *=/ { \
        p; \
        s|.*||p; \
        s|.*|SUPPORT = ${EPICS_SYNAPPS}|p; \
        s|.*|ASYN = \$(SUPPORT)/asyn-4-26|p; \
        s|.*|CALC = \$(SUPPORT)/calc-3-4-2-1|p; \
        s|.*|SSCAN = \$(SUPPORT)/sscan-2-10-1|p; \
    }" configure/RELEASE

cd streamDevice
rm GNUmakefile
cd ..

make install

if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/stream_${STREAM_DEVICE_VERSION}.tar.gz
fi

######################## Fix SynApps and rebuild #############################

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^STREAM=.*|STREAM=${STREAM_DEVICE_PATH}|" configure/RELEASE
sed -i -e "s|^STREAM=.*|STREAM=${STREAM_DEVICE_PATH}|" delaygen-1-1-1/configure/RELEASE

make clean uninstall install
