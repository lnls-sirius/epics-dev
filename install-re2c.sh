#!/bin/sh

set -e
set -x

. ./repo-versions.sh

distro="$(./get-os-distro.sh -d)"

case "$distro" in
    "Fedora" | "RedHat" | "Scientific")
        if [ "${DOWNLOAD_APP}" == "yes" ]; then
            # Download RPM
            curl -O http://dl.fedoraproject.org/pub/epel/7/x86_64/r/re2c-${RE2C_VERSION}.el7.x86_64.rpm
        fi

        if [ "${INSTALL_APP}" == "no" ]; then
            # Good for debug
            echo "Not installing re2c per user request (-i flag not set)"
            exit 0
        fi

        # Remove re2c that may be already installed
        sudo yum remove -y re2c

        # Install it
        sudo rpm -Uvh --replacepkgs re2c-${RE2C_VERSION}.el7.x86_64.rpm
        ;;
    *)
        if ! which re2c; then
            echo "re2c should have already been installed!" >&2
        fi
        ;;
esac
