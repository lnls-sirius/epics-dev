# EPICS v3/v4 installation scripts

Repository containing EPICS installation scripts. The idea is to simplify EPICS
installation by just running a single script and it will take care of: installing
the necessary system packages for the supported architectures (Debian 8/9,
Ubuntu > 14.04, Fedora > 24, CentOS > 6); installing EPICS base (3.14, 3.15, 3.16 or 7.0);
installing EPICS modules (only synApps R5_8 for now).

## Instructions

1. Select the desired EPICS base version by checking out to the
corresponding git branch:

For EPICS base 3.14 (same as master):

```
    git checkout base-3.14
    git checkout master
```

For EPICS base 3.15:

```
    git checkout base-3.15
```

For EPICS base 3.16:

```
    git checkout base-3.16
```

For EPICS base 7.0:

```
    git checkout base-7.0
```

2. Set the correct EPICS architecture by changing EPICS_HOST_ARCH variable in
the file "bash.bashrc.local".

```
    export EPICS_HOST_ARCH=linux-x86_64
```

for Linux x86 64-bits. If you have, for instance, a Linux x86 32-bits,
change the line above to

```
    export EPICS_HOST_ARCH=linux-x86
```

For other architectures, see the official EPICS documentation:
http://www.aps.anl.gov/epics/base/R3-14/12-docs/README.html

3. It's possible to customize all of the versions being installed
by changing the repo-versions.sh script.

Be advised, however, that some versions combination might not
work. Particularly when using most recent versions of EPICS (> 3.15)
and synApps R5_8.

There is a work in progress to use more recent versions os EPICS
modules, but this is not ready yet.

4. Run the master script and pass the desired options:

```
    ./run-all.sh -a no -e yes -x no [-n yes || -r yes] -t no -s yes -i -o -c
```

Use only -n OR -r option, not both.

The meaning of the options are:

```
    -a <install autotools from source = [yes|no]>
    -e <install EPICS tools = [yes|no]>
    -x <install EPICS V4 tools = [yes|no]>
    -n <install SynApps = [yes|no]>"
    -r <install SynApps LNLS = [yes|no]>"
    -t <install recent StreamDevice version (necessary by some IOCs)= [yes|no]>"
    -s <install system dependencies (necessary for EPICS tools) = [yes|no]>
    -i <install the packages>
    -o <download the packages>
    -c <cleanup the packages>
```

This will download/compile/install all the dependencies needed, as well as the
EPICS V3/V4 packages and tools.
