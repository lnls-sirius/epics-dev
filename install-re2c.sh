#!/bin/sh

set -e
set -x

. ./repo-versions.sh

distro="$(./get-os-distro.sh -d)"

case "$distro" in
    "Fedora" | "RedHat" | "Scientific")
        # Download RPM
        wget http://dl.fedoraproject.org/pub/epel/7/x86_64/r/re2c-${RE2C_VERSION}.el7.x86_64.rpm

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
