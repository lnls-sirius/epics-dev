#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

echo "Installing EPICS"

# Source environment variables
. ./env-vars.sh

# Source EPICS variables
. ./bash.bashrc.local

USER=$(whoami)
GROUP=$(groups ${USER} | cut -d' ' -f3)
TOP_DIR=$(pwd)
EPICS_ENV_DIR=/etc/profile.d
LDCONF_DIR=/etc/ld.so.conf.d
EPICS_EXTENSIONS_SRC=${EPICS_EXTENSIONS}/src

# Install EPICS base and used modules

# Source repo versions
. ./repo-versions.sh

EPICS_MSI=${EPICS_EXTENSIONS_SRC}/msi${MSI_VERSION}
EPICS_PROCSERV=${EPICS_EXTENSIONS_SRC}/procServ-${PROCSERV_VERSION}

EPICS_FULL_URL_VERSION=

concat_version_number () {
    set +u
    local version_number=( "$@" )
    local result

    for ver in "${version_number[@]}"; do
        if [ -z "${ver}" ]; then
            break
        fi

        # if not the first iteration append "." to compose
        # something like "<release>.<major>...."
        if [ ! -z "${result}" ]; then
            result=${result}"."
        fi

        result=${result}${ver}
    done

    echo "${result}"
    set -u
}

EPICS_FULL_URL_PREFIX=
case ${EPICS_BASE_RELEASE} in
    # EPICS 3
    "3")
        case ${EPICS_BASE_MAJOR} in
            # EPICS 3.14
            "14")
                EPICS_FULL_URL_PREFIX="R"
            ;;
            # EPICS 3.15 or EPICS 3.16
            "15" | "16")
                EPICS_FULL_URL_PREFIX="-"
            ;;
        esac
        ;;

    # EPICS 7
    "7")
        EPICS_FULL_URL_PREFIX="-"
        ;;
    esac

EPICS_FULL_VERSION=$(concat_version_number ${EPICS_BASE_RELEASE} \
    ${EPICS_BASE_MAJOR} \
    ${EPICS_BASE_MINOR} \
    ${EPICS_BASE_PATCH}
)
EPICS_FULL_URL_VERSION=${EPICS_FULL_URL_PREFIX}${EPICS_FULL_VERSION}

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    wget -nc https://epics.anl.gov/download/base/base${EPICS_FULL_URL_VERSION}.tar.gz
    wget -nc https://epics.anl.gov/download/extensions/extensionsTop_${EXTERNSIONS_VERSION}.tar.gz
    wget -nc https://epics.anl.gov/download/extensions/msi${MSI_VERSION}.tar.gz
    wget -nc http://downloads.sourceforge.net/project/procserv/${PROCSERV_VERSION}/procServ-${PROCSERV_VERSION}.tar.gz
fi

############################## EPICS Base #####################################

if [ "${INSTALL_APP}" == "no" ]; then
    # Good for debug
    echo "Not installing EPICS per user request (-i flag not set)"
    exit 0
fi

# Prepare environment
sudo mkdir -p ${EPICS_FOLDER}
sudo chmod 755 ${EPICS_FOLDER}
sudo chown ${USER}:${GROUP} ${EPICS_FOLDER}

distro=$(./get-os-distro.sh -d)
rev=$(./get-os-distro.sh -r)

# For Debian, use ~/.bashrc, as debian docker is not reading /etc/profile
if [ "$distro" == "Debian" ]; then
    sudo bash -c "cat ${TOP_DIR}/bash.bashrc.local >> ~/.bashrc"
else
    # Copy EPICS environment variables to profile
    sudo bash -c "cat ${TOP_DIR}/bash.bashrc.local >> /etc/profile.d/epics.sh"
fi

# Extract and install EPICS
cd ${EPICS_FOLDER}
tar xvzf ${TOP_DIR}/base${EPICS_FULL_URL_VERSION}.tar.gz

# Remove possible existing symlink
rm -f base
# Symlink to EPICS base
ln -sf base-${EPICS_BASE_VERSION} base

# Update ldconfig with EPICS libs
sudo touch ${LDCONF_DIR}/epics.conf
echo "${EPICS_BASE}/lib/${EPICS_HOST_ARCH}" | sudo tee -a /etc/ld.so.conf.d/epics.conf
echo "/usr/lib64" | sudo tee -a /etc/ld.so.conf.d/epics.conf
echo "/lib64" | sudo tee -a /etc/ld.so.conf.d/epics.conf
echo "/usr/lib" | sudo tee -a /etc/ld.so.conf.d/epics.conf

# Update ldconfig cache
sudo ldconfig

# Compile EPICS base
cd ${EPICS_BASE}
make
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

############################ EPICS Extensions ##################################

# Extract and install extensions
cd ${EPICS_FOLDER}
tar xvzf ${TOP_DIR}/extensionsTop_${EXTERNSIONS_VERSION}.tar.gz

# Jump to dir and compile
cd ${EPICS_EXTENSIONS}
make
make install
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

########################### EPICS msi Extension ################################

cd ${EPICS_EXTENSIONS_SRC}
tar xvzf ${TOP_DIR}/msi${MSI_VERSION}.tar.gz

cd ${EPICS_MSI}
make
make install
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

######################### EPICS procServ Extension #############################

cd ${EPICS_EXTENSIONS_SRC}
tar xvzf ${TOP_DIR}/procServ-${PROCSERV_VERSION}.tar.gz

cd ${EPICS_PROCSERV}
./configure
make
sudo make install
if [ "${CLEANUP_APP}" == "yes" ]; then
    make clean
fi

######################## Clean up downloaded files #############################

if [ "${DOWNLOAD_APP}" == "yes" ] && [ "${CLEANUP_APP}" == "yes" ]; then
    rm -f ${TOP_DIR}/base${EPICS_FULL_URL_VERSION}.tar.gz
    rm -f ${TOP_DIR}/extensionsTop_${EXTERNSIONS_VERSION}.tar.gz
    rm -f ${TOP_DIR}/msi${MSI_VERSION}.tar.gz
    rm -f ${TOP_DIR}/procServ-${PROCSERV_VERSION}.tar.gz
fi

# Source environment file so users can issue EPICS commands right after installation
# For Debian, use ~/.bashrc, as debian docker is not reading /etc/profile
if [ "$distro" == "Debian" ]; then
    . ~/.bashrc
else
    # Copy EPICS environment variables to profile
    . /etc/profile.d/epics.sh
fi

echo "EPICS installation successfully completed"
