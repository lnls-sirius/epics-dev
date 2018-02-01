#!/usr/bin/env bash

# Exit on error
set -e
# Check for uninitialized variables
set -u

VALID_EPICS_CFG_STR="Valid values are: \"yes\" and \"no\"."
VALID_EPICS_V4_CFG_STR="Valid values are: \"yes\" and \"no\"."
VALID_SYNAPPS_CFG_STR="Valid values are: \"yes\" and \"no\"."
VALID_STREAM_DEVICE_CFG_STR="Valid values are: \"yes\" and \"no\"."
VALID_CA_GATEWAY_CFG_STR="Valid values are: \"yes\" and \"no\"."
VALID_SYSTEM_DEPS_CFG_STR="Valid values are: \"yes\" and \"no\"."

# Ask sudo password only once and keep updating sudo timestamp to
# avoid asking again
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || \
    exit; done 2>/dev/null &

# Source environment variables
. ./env-vars.sh

# Source repo versions
. ./repo-versions.sh

function usage {
    echo "Usage: $0 "
    echo "    -a <install autotools from source = [yes|no]>"
    echo "    -e <install EPICS tools = [yes|no]>"
    echo "    -x <install EPICS V4 tools = [yes|no]>"
    echo "    -n <install SynApps = [yes|no]>"
    echo "    -t <install StreamDevice ${STREAM_DEVICE_VERSION} = [yes|no]>"
    echo "    -g <install CA Gateway ${CA_GATEWAY_VERSION} = [yes|no]>"
    echo "    -s <install system dependencies = [yes|no]>"
    echo "    -i <install the packages>"
    echo "    -o <download the packages>"
    echo "    -c <cleanup the packages>"
}

# Select if we want autotools or not. Options are: yes or no
AUTOTOOLS_CFG="no"
# Select if we want epics or not. Options are: yes or no
EPICS_CFG="no"
# Select if we want epics V4 or not. Options are: yes or no
EPICS_V4_CFG="no"
# Select if we want to install SynApps. Options are: yes or no
SYNAPPS_CFG="no"
# Select if we want to install a new version of Stream Device. Options are: yes or no
STREAM_DEVICE_CFG="no"
# Select if we want to install a new version of CA Gateway. Options are: yes or no
CA_GATEWAY_CFG="no"
# Select if we want to install system dependencies or not. Options are: yes or no
SYSTEM_DEPS_CFG="no"
# Select if we want to install the packages or not. Options are: yes or no
INSTALL_APP="no"
# Select if we want to download the packages or not. Options are: yes or no
DOWNLOAD_APP="no"
# Select if we want to cleanup the packages or not. This only removes intermediate
# files, that are not needed after the build. Options are: yes or no
CLEANUP_APP="no"

# Get command line options
while getopts ":a:e:x:s:n:t:g:ioc" opt; do
    case $opt in
        a)
            AUTOTOOLS_CFG=$OPTARG
            ;;
        e)
            EPICS_CFG=$OPTARG
            ;;
        x)
            EPICS_V4_CFG=$OPTARG
            ;;
        n)
            SYNAPPS_CFG=$OPTARG
            ;;
        t)
            STREAM_DEVICE_CFG=$OPTARG
            ;;
        g)
            CA_GATEWAY_CFG=$OPTARG
            ;;
        s)
            SYSTEM_DEPS_CFG=$OPTARG
            ;;
        i)
            INSTALL_APP="yes"
            ;;
        o)
            DOWNLOAD_APP="yes"
            ;;
        c)
            CLEANUP_APP="yes"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1
            ;;
    esac
done

if [ -z "$AUTOTOOLS_CFG" ]; then
    echo "Option \"-a\" unset. "$VALID_AUTOTOOLS_CFG_STR
    usage
    exit 1
fi

if [ "$AUTOTOOLS_CFG" != "yes" ] && [ "$AUTOTOOLS_CFG" != "no" ]; then
    echo "Option \"-a\" has unsupported option. "$VALID_AUTOTOOLS_CFG_STR
    usage
    exit 1
fi

if [ -z "$EPICS_CFG" ]; then
    echo "Option \"-e\" unset. "$VALID_EPICS_CFG_STR
    usage
    exit 1
fi

if [ "$EPICS_CFG" != "yes" ] && [ "$EPICS_CFG" != "no" ]; then
    echo "Option \"-e\" has unsupported option. "$VALID_EPICS_CFG_STR
    usage
    exit 1
fi

if [ -z "$EPICS_V4_CFG" ]; then
    echo "Option \"-x\" unset. "$VALID_EPICS_V4_CFG_STR
    usage
    exit 1
fi

if [ "$EPICS_V4_CFG" != "yes" ] && [ "$EPICS_V4_CFG" != "no" ]; then
    echo "Option \"-x\" has unsupported option. "$VALID_EPICS_V4_CFG_STR
    usage
    exit 1
fi

if [ -z "$SYNAPPS_CFG" ]; then
    echo "Option \"-n\" unset. "$VALID_SYNAPPS_CFG_STR
    usage
    exit 1
fi

if [ "$SYNAPPS_CFG" != "yes" ] && [ "$SYNAPPS_CFG" != "no" ]; then
    echo "Option \"-n\" has unsupported option. "$VALID_SYNAPPS_CFG_STR
    usage
    exit 1
fi

if [ -z "$STREAM_DEVICE_CFG" ]; then
    echo "Option \"-n\" unset. "$VALID_STREAM_DEVICE_CFG_STR
    usage
    exit 1
fi

if [ "$STREAM_DEVICE_CFG" != "yes" ] && [ "$STREAM_DEVICE_CFG" != "no" ]; then
    echo "Option \"-n\" has unsupported option. "$VALID_STREAM_DEVICE_CFG_STR
    usage
    exit 1
fi

if [ -z "$CA_GATEWAY_CFG" ]; then
    echo "Option \"-g\" unset. "$VALID_CA_GATEWAY_CFG_STR
    usage
    exit 1
fi

if [ "$CA_GATEWAY_CFG" != "yes" ] && [ "$CA_GATEWAY_CFG" != "no" ]; then
    echo "Option \"-g\" has unsupported option. "$VALID_CA_GATEWAY_CFG_STR
    usage
    exit 1
fi

if [ -z "$SYSTEM_DEPS_CFG" ]; then
    echo "Option \"-s\" unset. "$VALID_SYSTEM_DEPS_CFG_STR
    usage
    exit 1
fi

if [ "$SYSTEM_DEPS_CFG" != "yes" ] && [ "$SYSTEM_DEPS_CFG" != "no" ]; then
    echo "Option \"-s\" has unsupported option. "$VALID_SYSTEM_DEPS_CFG_STR
    usage
    exit 1
fi

# Check for uninitialized variables
set -u

# Export children variables
export INSTALL_APP
export DOWNLOAD_APP
export CLEANUP_APP

######################## System Dependencies Installation ######################

if [ "$SYSTEM_DEPS_CFG" == "yes" ]; then
    ./get-system-deps.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not compile/install system dependencies." >&2
        exit 1
    fi

    ./fix-system-deps.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not fix system dependencies." >&2
        exit 1
    fi
fi

############################ Autotools Installation ############################

# Check if we want to install autotools
if [ "$AUTOTOOLS_CFG" == "yes" ]; then
    ./get-autotools.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not compile/install project autotools." >&2
        exit 1
    fi
fi

############################## EPICS Installation ##############################

# Check if we want to install epics
if [ "$EPICS_CFG" == "yes" ]; then
    ./get-epics.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not compile/install project epics." >&2
        exit 1
    fi
fi

############################ SynApps Installation ##############################

# Check if we want to install epics
if [ "$SYNAPPS_CFG" == "yes" ]; then
    ./get-synapps.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not compile/install project synapps." >&2
        exit 1
    fi
fi

############################## EPICS V4 Installation ##############################

# Check if we want to install epics
if [ "$EPICS_V4_CFG" == "yes" ]; then
    ./get-epics-v4.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not compile/install project epics V4." >&2
        exit 1
    fi
fi

######################### Stream Device Installation ###########################

# Check if we want to install new version of Stream Device
if [ "$STREAM_DEVICE_CFG" == "yes" ]; then
    ./get-stream-device.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not compile/install new version of Stream Device." >&2
        exit 1
    fi
fi

######################### CA Gateway Installation ###########################

# Check if we want to install new version of Stream Device
if [ "$CA_GATEWAY_CFG" == "yes" ]; then
    ./get-ca-gateway.sh

    # Check last command return status
    if [ $? -ne 0 ]; then
        echo "Could not compile/install new version of CA Gateway." >&2
        exit 1
    fi
fi

echo "EPICS installation completed"
