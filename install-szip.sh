#!/usr/bin/env bash

set -e
set -x

# Source environment variables
. ./env-vars.sh

# Source repo versions
. ./repo-versions.sh

# Download RPM
if [ "${DOWNLOAD_APP}" == "yes" ]; then
    curl -O https://support.hdfgroup.org/ftp/lib-external/szip/${SZIP_VERSION}/src/szip-${SZIP_VERSION}.tar.gz
fi

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing szip per user request (-i flag not set)"
    exit 0
fi

# Install it
tar xvf szip-${SZIP_VERSION}.tar.gz
cd szip-${SZIP_VERSION}
./configure --libdir=${SZIP_LIB} --includedir=${SZIP_INCLUDE}
make
sudo make install
cd ..

if [ "${CLEANUP_APP}" == "yes" ]; then
    cd szip-${SZIP_VERSION}
    make clean
    cd ..
fi

# Add symlinks. This won't work as this link is only done
# in the host image and not the generated one.
sudo ln -sf ${SZIP_LIB}/libsz.so.2 ${SZIP_LIB}/libsz.so || /bin/true
