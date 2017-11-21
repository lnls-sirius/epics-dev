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

mkdir -p "$STREAM_DEVICE_PATH"
cd "$STREAM_DEVICE_PATH"

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    git clone https://github.com/paulscherrerinstitute/StreamDevice.git streamDevice
fi

if [ "${INSTALL_APP}" == "yes" ] && [ ! -d "./streamDevice" ]; then
    echo "StreamDevice files are not available on ${STREAM_DEVICE_PATH}/streamDevice" >&2
    exit 1
fi

/opt/epics/base/bin/linux-x86_64/makeBaseApp.pl -t support -u "$USER"

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
    /#SNCSEQ=/ { \
        p; \
        s|.*||p; \
        s|.*|SUPPORT = ${EPICS_SYNAPPS}|p; \
        s|.*|ASYN = \$(SUPPORT)/asyn-4-26|p; \
        s|.*|CALC = \$(SUPPORT)/calc-3-4-2-1|p; \
        s|.*|SSCAN = \$(SUPPORT)/sscan-2-10-1|p; \
    }" configure/RELEASE

cd streamDevice
git checkout stream_2_7_7
rm GNUmakefile
cd ..

make install

if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

# Replace SynApps Stream Device
cd "$EPICS_SYNAPPS"

sed -i -e "s|^STREAM=.*|STREAM=${STREAM_DEVICE_PATH}|" configure/RELEASE
sed -i -e "s|^STREAM=.*|STREAM=${STREAM_DEVICE_PATH}|" delaygen-1-1-1/configure/RELEASE

make clean uninstall install
