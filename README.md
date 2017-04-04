# EPICS v3/v4 installation scripts

Repository containing all of the third-party libraries needed by with our
Software, as well as Gateware and client applications.

## Instructions

    ./run-all.sh -a yes -e yes -x yes -s yes -i -o

The meaning of the options are:

    -a <install autotools = [yes|no]>
    -e <install EPICS tools = [yes|no]>
    -x <install EPICS V4 tools = [yes|no]>
    -s <install system dependencies = [yes|no]>
    -i <install the packages>
    -o <download the packages>

This will download/compile/install all the dependencies needed, as well as the
EPICS V3/V4 packages and tools

If you are installing EPICS tools (-e yes option), be sure to check the
file epics.sh and select the correct value for the EPICS_HOST_ARCH variable.
By default, the value is

```
export EPICS_HOST_ARCH=linux-x86_64
```

for Linux x86 64-bits. If you have, for instance, a Linux x86 32-bits,
change the line above to

```
export EPICS_HOST_ARCH=linux-x86
```

For other architectures, see the official EPICS 3.14.12 documentation:
http://www.aps.anl.gov/epics/base/R3-14/12-docs/README.html
