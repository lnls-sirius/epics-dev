#!/usr/bin/env bash

# Autotools
PKG_CONFIG_VERSION=0.26
M4_VERSION=1.4.17
AUTOCONF_VERSION=2.69
AUTOMAKE_VERSION=1.14.1
LIBTOOL_VERSION=2.4.2

# EPICS
EPICS_BASE_VERSION=7.0.1.1
EXTERNSIONS_VERSION=20120904
MSI_VERSION=1-6
PROCSERV_VERSION=2.7.0
SYNAPPS_VERSION=5_8
SYNAPPS_LNLS_VERSION=1-1-2
SYNAPPS_LNLS_VERSION_TR=R$(echo ${SYNAPPS_LNLS_VERSION} | tr "." "-")
STREAM_DEVICE_VERSION=2_7_7
STREAM_DEVICE_VERSION_TR=$(echo ${STREAM_DEVICE_VERSION} | tr "._" "-")
IOC_STATS_VERSION=3.1.15
IOC_STATS_VERSION_TR=$(echo ${IOC_STATS_VERSION} | tr "." "-")
SEQ_VERSION=2.2.5
SEQ_VERSION_TR=$(echo ${SEQ_VERSION} | tr "." "-")
CAPUT_RECORDER_VERSION=1-7
CAPUT_RECORDER_VERSION_TR=$(echo ${CAPUT_RECORDER_VERSION} | tr "." "-")
CAPUT_RECORDER_VERSION_RELEASE=R${CAPUT_RECORDER_VERSION}
AUTOSAVE_VERSION=5-9
AUTOSAVE_VERSION_TR=$(echo ${AUTOSAVE_VERSION} | tr "." "-")
AUTOSAVE_VERSION_RELEASE=R${AUTOSAVE_VERSION}
IPAC_VERSION=2.14
IPAC_VERSION_TR=$(echo ${IPAC_VERSION} | tr "." "-")
CALC_VERSION=3-7
CALC_VERSION_TR=$(echo ${CALC_VERSION} | tr "." "-")
CALC_VERSION_RELEASE=R${CALC_VERSION}
SZIP_VERSION=2.1.1
RE2C_VERSION=0.14.3-2
HDF5_VERSION=1.10.5

# EPICS V4
EPICS_V4_BASE_VERSION=4.6.0

# Split EPICS version fields
EPICS_BASE_RELEASE=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f1)
EPICS_BASE_MAJOR=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f2)
EPICS_BASE_MINOR=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f3)
EPICS_BASE_PATCH=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f4)
