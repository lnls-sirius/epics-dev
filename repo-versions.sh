#!/usr/bin/env bash

# Autotools
PKG_CONFIG_VERSION=0.26
M4_VERSION=1.4.17
AUTOCONF_VERSION=2.69
AUTOMAKE_VERSION=1.14.1
LIBTOOL_VERSION=2.4.2

# EPICS
EPICS_BASE_VERSION=3.14.12.6
EXTERNSIONS_VERSION=20120904
MSI_VERSION=1-6
PROCSERV_VERSION=2.7.0
SYNAPPS_VERSION=5_8
STREAM_DEVICE_VERSION=2_7_7
IOC_STATS_VERSION=3.1.15
SEQ_VERSION=2.2.5
CAPUT_RECORDER_VERSION=R1-7
AUTOSAVE_VERSION=R5-9
SZIP_VERSION=2.1.1
RE2C_VERSION=0.14.3-2
HDF5_VERSION=1.10.1

# EPICS V4
EPICS_V4_BASE_VERSION=4.6.0

# Split EPICS version fields
EPICS_BASE_RELEASE=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f1)
EPICS_BASE_MAJOR=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f2)
EPICS_BASE_MINOR=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f3)
EPICS_BASE_PATCH=$(echo "${EPICS_BASE_VERSION}" | cut -d'.' -f4)
