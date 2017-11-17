#!/bin/sh

set -e
set -x

# Source environment variables
. ./env-vars.sh

# Source repo versions
. ./repo-versions.sh

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    # Download source
    curl -O https://support.hdfgroup.org/ftp/HDF5/current/src/hdf5-${HDF5_VERSION}.tar.gz
fi

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing hdf5 per user request (-i flag not set)"
    exit 0
fi

# Install it
tar xvf hdf5-${HDF5_VERSION}.tar.gz
cd hdf5-${HDF5_VERSION}

./configure --libdir=${HDF5_LIB} --includedir=${HDF5_INCLUDE}
make
sudo make install
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

cd ..
