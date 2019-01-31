#!/usr/bin/env bash

# Check for uninitialized variables
set -u
# Exit on error
set -e

# Dependency list
GEN_DEPS="\
    binutils \
    git \
    re2c \
    automake \
    autoconf \
    make \
    libtool \
    curl
"
DEB_UBU_PERL_DEPS="\
    libextutils-cchecker-perl \
    libextutils-f77-perl \
    libextutils-libbuilder-perl \
    libextutils-pkgconfig-perl \
    libextutils-xsbuilder-perl \
    libextutils-xspp-perl
"
DEB_UBU_GEN_DEPS="\
    build-essential \
    g++ \
    glib2.0 \
    libglib2.0 \
    libglib2.0-dev \
    uuid-dev \
    libreadline6 \
    libreadline6-dev \
    libusb-dev \
    bzip2 \
    libbz2-dev \
    libxml2-dev \
    perl \
"
DEB_GEN_DEPS="\
    build-essential \
    g++ \
    glib2.0 \
    libglib2.0 \
    libglib2.0-dev \
    uuid-dev \
    libreadline7 \
    libreadline-dev \
    libusb-dev \
    bzip2 \
    libbz2-dev \
    libxml2-dev \
    perl \
"
UBU_18_04_GEN_DEPS="
    build-essential \
    g++ \
    glib2.0 \
    libglib2.0 \
    libglib2.0-dev \
    uuid-dev \
    libreadline-dev \
    libusb-dev \
    bzip2 \
    libbz2-dev \
    libxml2-dev \
    perl \
" 
UBU_16_10_GEN_DEPS="\
    build-essential \
    g++ \
    glib2.0 \
    libglib2.0 \
    libglib2.0-dev \
    uuid-dev \
    libreadline6 \
    libreadline6-dev \
    libusb-dev \
    bzip2 \
    libbz2-dev \
    libxml2-dev \
    perl \
"
UBU_16_GEN_DEPS="\
    build-essential \
    g++ \
    glib2.0 \
    libglib2.0 \
    libglib2.0-dev \
    uuid-dev \
    libreadline6 \
    libreadline6-dev \
    libusb-dev \
    bzip2 \
    libbz2-dev \
    libxml2-dev \
    perl \
"
UBU_12_GEN_DEPS="\
    build-essential \
    g++ \
    glib2.0 \
    libglib2.0 \
    libglib2.0-dev \
    uuid-dev \
    libreadline6 \
    libreadline6-dev \
    libusb-dev \
    bzip2 \
    libbz2-dev \
    libxml2-dev \
    perl \
"
DEB_UBU_DEPS="${DEB_UBU_GEN_DEPS} ${DEB_UBU_PERL_DEPS}"
DEB_DEPS="${DEB_GEN_DEPS} ${DEB_UBU_PERL_DEPS}"
UBU_18_04_DEPS="${UBU_18_04_GEN_DEPS} ${DEB_UBU_PERL_DEPS}"
UBU_16_10_DEPS="${UBU_16_10_GEN_DEPS} ${DEB_UBU_PERL_DEPS}"
UBU_16_DEPS="${UBU_16_GEN_DEPS} ${DEB_UBU_PERL_DEPS}"
UBU_12_DEPS="${UBU_12_GEN_DEPS} ${DEB_UBU_PERL_DEPS}"

FED_RED_SUS_DEPS="\
    which \
    wget \
    gcc-c++ \
    glib2 \
    glib2-devel \
    uuid-devel \
    readline \
    readline-devel \
    libusb-devel \
    bzip2-devel \
    libxml2-devel \
    perl \
    perl-devel \
    perl-ExtUtils* \
    perl-Pod-Checker \
"

echo "Installing system dependencies"

distro=$(./get-os-distro.sh -d)
rev=$(./get-os-distro.sh -r)

case $distro in
    "Ubuntu")
        # Ubuntu 16 changed some package names
        if [ "$rev" \< "12.04" ] || [ "$rev" == "12.04" ]; then
            DEPS="${GEN_DEPS} ${UBU_12_DEPS}"
        elif [ "$rev" == "18.04" ]; then
            DEPS="${GEN_DEPS} ${UBU_18_04_DEPS}"
        elif [ "$rev" == "16.04" ]; then
            DEPS="${GEN_DEPS} ${UBU_16_DEPS}"
        elif [ "$rev" == "16.10" ]; then
            DEPS="${GEN_DEPS} ${UBU_16_10_DEPS}"
        else
            DEPS="${GEN_DEPS} ${DEB_UBU_DEPS}"
        fi

        PKG_MANAGER="apt-get"
        PKG_UPDT_COMMAND="update"
        PKG_INSTALL_COMMAND="install -y"
        ;;
    "Debian")
        DEPS="${GEN_DEPS} ${DEB_DEPS}"
        PKG_MANAGER="apt-get"
        PKG_UPDT_COMMAND="update"
        PKG_INSTALL_COMMAND="install -y"
        ;;
    "Fedora" | "RedHat" | "Scientific")
        PKG_MANAGER="yum"
        PKG_UPDT_COMMAND="makecache"
        PKG_INSTALL_COMMAND="install -y"
        DEPS="${GEN_DEPS} ${FED_RED_SUS_DEPS}"
        ;;
    "SUSE")
        PKG_MANAGER="zypper"
        PKG_UPDT_COMMAND="update"
        # Not sure if this will assume "yes"" for every package, but zypper does
        # not seem to have an equivalent -y option
        PKG_INSTALL_COMMAND="--non-interactive --no-gpg-checks --quiet install \
            --auto-agree-with-licenses"
        DEPS="${GEN_DEPS} ${FED_RED_SUS_DEPS}"
        ;;
    *)
        echo "Unsupported distribution: $distro" >&2
        exit 1
        ;;
esac

if [ "${DOWNLOAD_APP}" == "yes" ]; then
    # Update repos
    sudo ${PKG_MANAGER} ${PKG_UPDT_COMMAND}
    sudo ${PKG_MANAGER} ${PKG_INSTALL_COMMAND} ${DEPS}

    # Install missing dependencies not available on repos
    ./install-re2c.sh
fi

echo "System dependencies installation completed"
